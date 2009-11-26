require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'AtokTwitter' do
  describe 'extra' do
    it 'has all required files' do
      @extra_files.each do |file|
        File.file?(File.join(@extra_root, file)).should be_true
      end
    end
  end

  describe 'plugin' do
    it 'has all required files' do
      @plugin_files.each do |file|
        File.file?(File.join(@plugin_root, file)).should be_true
      end
    end
  end
end
