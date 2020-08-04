class ProgrammeToIatiStatus
  def programme_status_to_iati_status(programme_status)
    return nil if programme_status.blank?
    programme_status_to_iati_status_mapping.find { |pair| pair["programme-status"] == programme_status }["iati-status"]
  end

  def programme_status_to_iati_status_mapping
    yaml = YAML.safe_load(File.read("#{Rails.root}/vendor/data/codelists/BEIS/programme_status_to_iati_status_mapping.yml"))
    yaml["data"]
  end
end
