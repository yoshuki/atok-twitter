require 'win32ole'

class ATOK
  class Twitter
    class Installer
      def initialize(plugin_root)
        @plugin_root = plugin_root
        @sc = WIN32OLE.new("ScriptControl")
        @sc.language = 'VBScript'
      end

      def install
        login_info = get_login_info
        if login_info[:user] && login_info[:pass]
          if login_info[:user].index("}") || login_info[:pass].index("}")     # �V���^�b�N�X�G���[�̉\��
            @sc.eval('MsgBox("���[�U�[���܂��̓p�X���[�h�Ɂu}�v���܂߂邱�Ƃ͂ł��܂���B", vbOKOnly Or vbCritical, "Twitter")')
          else
            set_login_info(login_info)
            system(File.join(@plugin_root, 'SETUP.EXE'))
          end
        else
          @sc.eval('MsgBox("�C���X�g�[���O�Ƀ��O�C�����̐ݒ肪�K�v�ł��B", vbOKOnly Or vbCritical, "Twitter")')
        end
      end

      private
      def get_login_info
        while true
          user = @sc.eval('InputBox("���[�U�[��", "Twitter")')
          if user.nil?
            break
          elsif !(user =~ /^[0-9A-Z_]+$/i)
            @sc.eval('MsgBox("���[�U�[��������������܂���B", vbOKOnly Or vbExclamation, "Twitter")')
            redo
          end

          raise '���[�U�[����������' unless user
          while true
            pass = @sc.eval('InputBox("�p�X���[�h", "Twitter")')
            break if pass.nil?

            raise '�p�X���[�h��������' unless pass
            pass_confirm = @sc.eval('InputBox("�p�X���[�h�m�F", "Twitter")')
            redo if pass_confirm.nil?

            raise '�p�X���[�h�m�F��������' unless pass_confirm
            break if pass == pass_confirm

            @sc.eval('MsgBox("�p�X���[�h����v���܂���B", vbOKOnly Or vbExclamation, "Twitter")')
          end

          if user && pass
            answer = @sc.eval('MsgBox("���[�U���F'+user+'"&vbCrLf&"�p�X���[�h�F*****"&vbCrLf&vbCrLf&"��낵���ł����H", vbYesNoCancel Or vbQuestion, "Twitter")')
            case answer
            when @sc.eval('vbYes'); break
            when @sc.eval('vbNo'); redo
            else
              user = pass = nil
              break
            end
          end
        end

        {:user => user, :pass => pass}
      end

      def set_login_info(login_info)
        twitter_rb = File.read(File.join(@plugin_root, 'DATA', 'twitter_wo_login_info.rb'))
        twitter_rb.sub!(/TW_SCREEN_NAME *= *'.*?'/, "TW_SCREEN_NAME = %q{#{login_info[:user]}}").sub!(/TW_PASSWORD *= *'.*?'/, "TW_PASSWORD = %q{#{login_info[:pass]}}")
        File.open(File.join(@plugin_root, 'DATA', 'twitter.rb'), 'w') {|f| f.write(twitter_rb)}
      end
    end
  end
end