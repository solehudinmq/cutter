require 'httparty'

# 3rdparty api call simulation.
class ThirdPartyService
  # method random simulation response from 3rd party
  def self.call(url, body, headers)
    response = HTTParty.post(url, 
      body: body,
      headers: headers,
      timeout: 3
    )
    
    response
  end
end