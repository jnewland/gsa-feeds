#kastner is effing awesome. that is all.
class Net::HTTP
  def self.multi_post_form(url, params)
    req = Post.new(url.path)
    req.multipart_params = params
    req.basic_auth url.user, url.password if url.user
    new(url.host, url.port).start {|http|
      http.request(req)
    }
  end
end
  
module Net
  class HTTP
    class Post
      def multipart_params=(param_hash={})
        boundary_token = [Array.new(8) {rand(256)}].join
        self.content_type = "multipart/form-data; boundary=#{boundary_token}"
        boundary_marker = "--#{boundary_token}\r\n"
        
        self.body = param_hash.map { |param_name, param_value|
          boundary_marker + text_to_multipart(param_name, param_hash.delete(param_name).to_s) unless param_value.respond_to?(:read)
        }.join('') 
        
        self.body += param_hash.map { |param_name, param_value|
          boundary_marker + file_to_multipart(param_name, param_value)
        }.join('') 
        
        self.body += "--#{boundary_token}--\r\n"
      end

    protected
  
      def file_to_multipart(key,file)
        filename = File.basename(file.path || file.base_uri.to_s)
        mime_type = "application/octet-stream"
        part = %Q|Content-Disposition: form-data; name=\"#{key}\"; filename="#{filename}"\r\n|
        part += "Content-Transfer-Encoding: binary\r\n"
        part += "Content-Type: #{mime_type}\r\n\r\n#{file.read}\r\n"
      end

      def text_to_multipart(key,value)
        "Content-Disposition: form-data; name=\"#{key}\"\r\n\r\n#{value}\r\n"
      end
    end
  end
end