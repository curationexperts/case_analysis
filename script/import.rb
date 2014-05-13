#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '../config/environment.rb')

unless ARGV[0]
  puts "Usage: #{__FILE__} <username> <password> <start_at>\n"
  exit  
end
user = ARGV[0]
password = ARGV[1]
start_at = ARGV[2] ? ARGV[2].to_i : 0
fedora_url = 'http://digitalcase.case.edu:9000/fedora'

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
    next if i < start_at
    puts "I: #{i}"
    begin
      @solr_conn.add index_digital_object(object)
    rescue Rubydora::FedoraInvalidRequest => e
      puts "ERROR #{e}"
    end
    @solr_conn.commit(softCommit: true) if i % 100 == 0
  end
  @solr_conn.commit
end

def index_digital_object(object)
  docs = object.datastreams.map do |_, ds|
    index_datastream(ds)
  end
  docs << {id: object.pid, type_ssi: OBJECT, ds_count_isi: docs.size, aggregate_size_lsi: docs.map { |e| e[:size_lsi] }.sum }
end

def index_datastream(ds)
  {id: [ds.pid, ds.dsid].join('-'), pid_ssi: ds.pid, dsid_ssi: ds.dsid, label_ssi: ds.dsLabel, size_lsi: ds.dsSize, mime_ssi: ds.mimeType, 
   location_ss: ds.dsLocation, control_group_ssi: ds.controlGroup, type_ssi: DATASTREAM}
end


repo = Rubydora.connect url: fedora_url, user: user, password: password
@solr_conn = Blacklight.solr
reindex_everything(repo)

