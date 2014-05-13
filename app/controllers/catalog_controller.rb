# -*- encoding : utf-8 -*-
#
class CatalogController < ApplicationController  

  include Blacklight::Catalog

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = { 
      :qt => 'search',
      :rows => 10 
    }
    
    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select' 
    
    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or 
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  :qt => 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}' 
    #}

    # solr field configuration for search results/index views
    config.index.title_field = 'label_ssi'
    config.index.display_type_field = 'type_ssi'

    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.    
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or 
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.  
    #
    # :show may be set to false if you don't want the facet to be drawn in the 
    # facet bar
    config.add_facet_field 'type_ssi', :label => 'Type'
    config.add_facet_field 'dsid_ssi', :label => 'Datastream ID', :limit => 20 
    config.add_facet_field 'label_ssi', :label => 'Datastream Label', :limit => 20 
    config.add_facet_field 'mime_ssi', :label => 'Content-type' 
    config.add_facet_field 'control_group_ssi', :label => 'Control Group' 

    config.add_facet_field 'ds_count_isi', :label => 'Datastream Count', :query => {
       :size_tiny => { :label => '4 or fewer', :fq => "ds_count_isi:[* TO 4]" },
       :size_small => { :label => '5 to 50', :fq => "ds_count_isi:[5 TO 50]" },
       :size_medium => { :label => '51 to 100', :fq => "ds_count_isi:[51 TO 100]" },
       :size_big => { :label => 'More than 100', :fq => "ds_count_isi:[101 TO *]" }
    }
    config.add_facet_field 'aggregate_size_lsi', :label => 'Aggregate Size', :query => {
       :size_tiny => { :label => 'Less than 1MB', :fq => "aggregate_size_lsi:[* TO 1000000]" },
       :size_small => { :label => '1MB to 10MB', :fq => "aggregate_size_lsi:[1000001 TO 10000000]" },
       :size_medium => { :label => '10MB to 1GB', :fq => "aggregate_size_lsi:[10000001 TO 1000000000]" },
       :size_big => { :label => 'Larger than 1GB', :fq => "aggregate_size_lsi:[1000000001 TO *]" }
    }


  #     docs << {id: object.pid, type_ssi: OBJECT, ds_count_isi: docs.size, aggregate_size_lsi: docs.map { |e| e[:size_lsi] }.sum }
  # {id: [ds.pid, ds.dsid].join('-'), dsid_ssi: ds.dsid, label_ssi: ds.dsLabel, size_lsi: ds.dsSize, mime_ssi: ds.mimeType, 
  #  location_ss: ds.dsLocation, control_group_ssi: ds.controlGroup, type_ssi: DATASTREAM}

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display 
    config.add_index_field 'type_ssi', :label => 'Type'
    config.add_index_field 'id', :label => 'Id', helper_method: :link_id
    config.add_index_field 'dsid_ssi', :label => 'Datastream ID'
    config.add_index_field 'pid_ssi', :label => 'Object ID'
    config.add_index_field 'label_ssi', :label => 'Label'
    config.add_index_field 'format', :label => 'Format'
    config.add_index_field 'mime_ssi', :label => 'Mime type'
    config.add_index_field 'size_lsi', :label => 'Datastream size'
    config.add_index_field 'aggregate_size_lsi', :label => 'Object Size'
    config.add_index_field 'ds_count_isi', :label => 'Number of datastreams'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display 
    # config.add_show_field 'title_display', :label => 'Title'
    # config.add_show_field 'title_vern_display', :label => 'Title'
    # config.add_show_field 'subtitle_display', :label => 'Subtitle'
    # config.add_show_field 'subtitle_vern_display', :label => 'Subtitle'
    # config.add_show_field 'author_display', :label => 'Author'
    # config.add_show_field 'author_vern_display', :label => 'Author'
    # config.add_show_field 'format', :label => 'Format'
    # config.add_show_field 'url_fulltext_display', :label => 'URL'
    # config.add_show_field 'url_suppl_display', :label => 'More Information'
    # config.add_show_field 'language_facet', :label => 'Language'
    # config.add_show_field 'published_display', :label => 'Published'
    # config.add_show_field 'published_vern_display', :label => 'Published'
    # config.add_show_field 'lc_callnum_display', :label => 'Call number'
    # config.add_show_field 'isbn_t', :label => 'ISBN'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different. 

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise. 
    
    config.add_search_field 'all_fields', :label => 'All Fields'
    

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields. 
    
    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params. 
      field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = { 
        :qf => '$title_qf',
        :pf => '$title_pf'
      }
    end
    
    config.add_search_field('author') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
      field.solr_local_parameters = { 
        :qf => '$author_qf',
        :pf => '$author_pf'
      }
    end
    
    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as 
    # config[:default_solr_parameters][:qt], so isn't actually neccesary. 
    config.add_search_field('subject') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
      field.qt = 'search'
      field.solr_local_parameters = { 
        :qf => '$subject_qf',
        :pf => '$subject_pf'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, type_ssi desc, size_lsi asc', :label => 'relevance'
    config.add_sort_field 'type_ssi desc, size_lsi asc', :label => 'type'
    config.add_sort_field 'size_lsi asc, type_ssi asc', :label => 'size'
    config.add_sort_field 'aggregate_size_lsi asc, type_ssi desc', :label => 'aggregate size'

    # If there are more than this many search results, no spelling ("did you 
    # mean") suggestion is offered.
    config.spell_max = 5
  end

end 
