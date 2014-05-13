module ApplicationHelper
  def link_id(doc)
    if doc[:document][:type_ssi] == 'Object'
      link_to_repo doc[:value], doc[:document][:id]
    else
      link_to_repo doc[:document][:pid_ssi], doc[:document][:pid_ssi]
    end
  end

  def link_to_repo(label, id)
    link_to label, "http://digitalcase.case.edu:9000/fedora/objects/#{id}/datastreams"
  end
end
