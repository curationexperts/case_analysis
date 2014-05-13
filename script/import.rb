#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '../config/environment.rb')

unless ARGV[0]
  puts "Usage: #{__FILE__} <username> <password>\n"
  exit  
end
user = ARGV[0]
password = ARGV[1]
fedora_url = 'http://digitalcase.case.edu:9000/fedora'
solr_url = 'http://localhost:8983/solr/'

OBJECT = 'Object'.freeze
DATASTREAM = 'Datastream'.freeze

# Using the fedora search (not solr), get every object and reindex it.
# @param [String] query a string that conforms to the query param format
#   of the underlying search's API
def reindex_everything(repo, query = '')
  i = 0
  repo.search(query) do |object|
    next if object.pid.start_with?('fedora-system:')
    i += 1
    puts "I: #{i}"
    @solr_conn.add index_digital_object(object)
    @solr_conn.commit if i % 1000 == 0
  end
  @solr_conn.commit
end

def index_digital_object(object)
  # TODO datastreams
  docs = object.datastreams.map do |_, ds|
    index_datastream(ds)
  end
  docs << {id: object.pid, type_ssi: OBJECT, ds_count_isi: docs.size, aggregate_size_lsi: docs.map { |e| e[:size_lsi] }.sum }
end

def index_datastream(ds)
  {id: [ds.pid, ds.dsid].join('-'), dsid_ssi: ds.dsid, label_ssi: ds.dsLabel, size_lsi: ds.dsSize, mime_ssi: ds.mimeType, 
   location_ss: ds.dsLocation, control_group_ssi: ds.controlGroup, type_ssi: DATASTREAM}
end


repo = Rubydora.connect url: fedora_url, user: user, password: password
@solr_conn = RSolr.connect(url: solr_url)
reindex_everything(repo)

