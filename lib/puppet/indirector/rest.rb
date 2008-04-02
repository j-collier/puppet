require 'net/http'
require 'uri'

# Access objects via REST
class Puppet::Indirector::REST < Puppet::Indirector::Terminus
    def network_fetch(path)
        Net::HTTP.get(URI.parse("http://127.0.0.1:34343/#{path}"))
    end
    
    def network_delete(path)
        Net::HTTP.start("127.0.0.1", 34343) {|x| x.delete("/#{path}").body }  # weird-ass net/http library
    end
    
    def find(name, options = {})
        network_result = network_fetch("#{indirection.name}/#{name}")
        raise YAML.load(network_result) if exception?(network_result)
        decoded_result = indirection.model.from_yaml(network_result)
    end
    
    def search(name, options = {})
        network_results = network_fetch("#{indirection.name}s/#{name}")
        raise YAML.load(network_results) if exception?(network_results)
        decoded_results = YAML.load(network_results.to_s).collect {|result| indirection.model.from_yaml(result) }
    end
    
    def destroy(name, options = {})
        network_result = network_delete("#{indirection.name}/#{name}")
        raise YAML.load(network_result) if exception?(network_result)
        decoded_result = YAML.load(network_result.to_s)      
    end
    
    def save
      
    end
    
  private
  
    def exception?(yaml_string)
      yaml_string =~ %r{--- !ruby/exception}
    end
end
