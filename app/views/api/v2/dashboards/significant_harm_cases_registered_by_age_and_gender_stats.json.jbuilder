# Significant Harm Cases by Protection Concern
# significant_harm_cases_registered_by_age_and_gender_stats

if @stats.class.eql?(Hash)
  json.set!(@stats.keys[0], @stats.values[0])
else
  json.data @stats
  json.labels ["Physical", "Psychological", "Neglect", "Exploitation", "Sexual Abuse"]
end
