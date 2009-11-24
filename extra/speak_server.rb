require 'logger'
require 'rinda/ring'
require 'rubygems'
require 'aqtk'

RETRY_TIMES = 5
RETRY_INTERVAL = 3

logger = Logger.new(File.join(File.dirname(File.expand_path(__FILE__)), 'log', "#{File.basename(__FILE__, '.*')}.log").tr('/', '\\'), 'daily')
logger.datetime_format = '%Y-%m-%d %H:%M '
logger.progname = File.basename(__FILE__, '.*')
logger.level = Logger::INFO

case ARGV[0]
when 'start', 'startlocal'
  retries = []
  loop do
    begin
      ts = nil
      if ARGV[0] == 'startlocal'
        ts = DRbObject.new_with_uri('druby://localhost:12345')
      else
        DRb.start_service
        puts DRb.uri
        ts = Rinda::RingFinger.primary
      end
      puts ts.inspect

      while message = ts.take([:message, String], false)
        puts message[1].tosjis
        logger.info(message[1].tosjis)
        AquesTalk::Da.play_sync(message[1].tosjis, 100)
        retries.clear
      end
    rescue => evar
      logger.error(evar.inspect)
      if retries.size < RETRY_TIMES
        retries << Time.now
        sleep RETRY_INTERVAL
      else
        logger.error(retries.inspect)
        break
      end
    end
  end
else
  puts "Usage: ruby #{File.basename(__FILE__)} [start]"
end
