# class IngestBcNewtIatiData < ActiveRecord::Migration[6.0]
#   def up
#     filenames = Dir["#{Rails.root}/vendor/data/iati_activity_data/bc/newt/*/real_and_complete_legacy_file.xml"]
#     delivery_partner = Organisation.find_by!(iati_reference: "GB-GOV-OT313")
#
#     ActiveRecord::Base.transaction do
#       filenames.each do |filename|
#         IngestIatiActivities.new(
#           delivery_partner: delivery_partner,
#           file_io: File.read(filename)
#         ).call
#       end
#     end
#   end

#   def down
#     raise ActiveRecord::IrreversibleMigration
#   end
# end
