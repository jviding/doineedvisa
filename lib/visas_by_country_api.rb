class VisasByCountryApi

  def self.visas_for(nationality)
    #muista tsekata cachen time to live!!!
    Rails.cache.fetch(nationality, expires_in: 24.hours) { fetch_visas_for(nationality) }
    #fetch_visas_for(nationality)
  end

  private

  def self.fetch_visas_for(nationality)
    url = "http://en.wikipedia.org/w/api.php?format=json&action=query&titles=Visa_requirements_for_"+nationality+"_citizens&prop=revisions&rvprop=content"
    response = HTTParty.get "#{url}"

    data = create_data(response)
    return write_to_file(nationality, data)
  end

  def self.word_check(word)
    if word == "" || word.index("cite web") != nil
      return ""
    elsif word.index("flag|") != nil
      return word.split('|')[1]+"+"
    else
      return word.split('|')[0]+"*"
    end
  end

  def self.write_to_file(nationality, data)
    filename = nationality + ".txt"
    File.open(Rails.root+"lib/visa_requirements/"+filename, 'w') { |f|
      f.puts "{\"countries\":["
      data.split("*").each do |i|
        if i.index("+") != nil
          input = to_json(i)
          if i.index("Zimbabwe") != nil
            f.puts input
            break
          else
            f.puts input+","
          end
        end
      end
      f.puts "]}"
    }
    return filename
  end

  def self.to_json(content)
    country = content.split("+")[0]
    visa = content.split("+")[1]
    return "{\"country\":\""+country+"\",\"visa\":\""+visa+"\"}"
  end

  def self.create_data(response)
    data = ""
    apu = ""
    sana = ""
    print = false
    response.to_s.split("").each do |i|
      if i == "{" && apu == "{"
        apu = ""
        print = true
      end
      if print == true && i != "{" && i != "}"
        sana += i
      end
      if i == "}" && apu == "}"
        data += word_check(sana)
        sana = ""
        print = false
      end
      apu = i
    end
    return data
  end

end