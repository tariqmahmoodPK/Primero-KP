# TODO Add Explanatory Comments

# cases_referral_to_agency_stats
# Cases Referral (To Agency )


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
