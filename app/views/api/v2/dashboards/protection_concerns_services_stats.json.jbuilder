# TODO Update the referencing comments after properly updating the files
# TODO Add Explanatory Comments

# protection_concerns_services_stats
# Percentage of Children who received Child Protection Services

json.data do
  @stats.each do |key, value|
    if key.to_s.eql?("permission")
      json.set!(key, value)
    else
      json.stats do
        json.set!(key, value)
      end
    end
  end
end
