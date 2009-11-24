require 'drb'
require 'net/http'; Net::HTTP.version_1_2
require 'time'
require 'rubygems'
require 'nokogiri'

module Atok_plugin
  TW_SCREEN_NAME = 'xxxxxxxxxx'         # あなたの「ユーザ名」に置き換えてください。
  TW_PASSWORD    = 'xxxxxxxxxx'         # あなたの「パスワード」に置き換えてください。

  def run_process(request)
    candidates = []

    begin
      ts = DRbObject.new_with_uri('druby://localhost:12345')
      ts = nil unless ts.respond_to?(:write)
    rescue DRb::DRbConnError => evar
      ts = nil
    end

    case request['composition_string']
    when /^(tw:|ｔｗ：)(.+)$/
      new_status = /^(tw:|ｔｗ：)(.+)$/.match(request['composition_string'])[2]
      return nil unless doc = post_request('http://twitter.com/statuses/update.xml', {:status => new_status})

      status = doc.xpath('/status')
      now = Time.now
      created_at = Time.parse(status.xpath('created_at').text)
      date_or_time = (now.month == created_at.month && now.day == created_at.day) ? created_at.strftime('%H:%M') : created_at.strftime('%m-%d')

      ts && ts.write([:message, status.xpath('text').text + '。'])

      candidates = [
        {'hyoki' => "[#{date_or_time}] " + status.xpath('user/screen_name').text,
         'comment_xhtml' => <<-EOT
           <?xml version="1.0" encoding="UTF-8" ?>
           <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
             <head><title>AtokDirect</title></head>
             <body>
               <table>
                 <tr>
                   <td rowspan="2"><img src="#{status.xpath('user/profile_image_url').text}" /></td>
                   <td>#{status.xpath('user/name').text}</td>
                 </tr>
                 <tr>
                   <td>#{status.xpath('user/screen_name').text}</td>
                 </tr>
               </table>
               <hr />
               <p>#{status.xpath('text').text}</p>
             </body>
           </html>
         EOT
        }
      ]
    when 'twtl', 'ｔｗｔｌ'
      return nil unless doc = get_response('http://twitter.com/statuses/friends_timeline.xml')

      doc.xpath('/statuses/status').each do |status|
        now = Time.now
        created_at = Time.parse(status.xpath('created_at').text)
        date_or_time = (now.month == created_at.month && now.day == created_at.day) ? created_at.strftime('%H:%M') : created_at.strftime('%m-%d')

        from_now = (now - created_at).to_i
        if from_now < 60
          from_now_text = from_now.to_s + '秒前'
        elsif from_now < 3600
          from_now_text = (from_now / 60).to_s + '分前'
        else
          from_now_m = (from_now % 3600) / 60
          from_now_h = (from_now - from_now_m) / 3600
          from_now_text = "#{from_now_h}時間#{from_now_m}分前"
        end

        ts && ts.write([:message, status.xpath('text').text + '。'])

        candidates <<
        {'hyoki' => "[#{date_or_time}] " + status.xpath('user/screen_name').text,
         'comment_xhtml' => <<-EOT
           <?xml version="1.0" encoding="UTF-8" ?>
           <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
             <head><title>AtokDirect</title></head>
             <body>
               <table>
                 <tr>
                   <td rowspan="2" style="padding-right: 1em;"><img src="#{status.xpath('user/profile_image_url').text}" /></td>
                   <td>#{status.xpath('user/name').text}</td>
                 </tr>
                 <tr>
                   <td>#{status.xpath('user/screen_name').text}</td>
                 </tr>
               </table>
               <hr />
               <p>#{status.xpath('text').text}</p>
               <div style="text-align: right;">---- #{from_now_text}</div>
             </body>
           </html>
         EOT
        }
      end
    else
      return nil
    end

    {'candidate' => candidates}
  end

  def run_callback(selected)
    selected['composition_string']
    selected['candidate_string']
  end

  private
  def post_request(url, params)
    return nil unless params.is_a?(Hash)
    res = nil
    uri = URI.parse(url)
    Net::HTTP.start(uri.host) do |http|
      req = Net::HTTP::Post.new(uri.path)
      req.basic_auth(TW_SCREEN_NAME, TW_PASSWORD)
      req.set_form_data(params)
      res = http.request(req)
    end
    return nil unless res.is_a?(Net::HTTPOK)
#    File.open(File.join(File.dirname(File.expand_path(__FILE__)), 'response.xml'), 'w') {|f| f.write(res.body)}
#    Nokogiri::XML.parse(File.read(File.join(File.dirname(File.expand_path(__FILE__)), 'response.xml')))
    Nokogiri::XML.parse(res.body)
  rescue TimeoutError => evar
    nil
  rescue => evar
    nil
  end

  def get_response(url)
    res = nil
    uri = URI.parse(url)
    Net::HTTP.start(uri.host) do |http|
      req = Net::HTTP::Get.new(uri.path)
      req.basic_auth TW_SCREEN_NAME, TW_PASSWORD
      res = http.request(req)
    end
    return nil unless res.is_a?(Net::HTTPOK)
#    File.open(File.join(File.dirname(File.expand_path(__FILE__)), 'response.xml'), 'w') {|f| f.write(res.body)}
#    Nokogiri::XML.parse(File.read(File.join(File.dirname(File.expand_path(__FILE__)), 'response.xml')))
    Nokogiri::XML.parse(res.body)
  rescue TimeoutError => evar
    nil
  rescue => evar
    nil
  end
end
