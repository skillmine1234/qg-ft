class NachMemberSearcher < Searcher
  attr_searchable :iin, :name, :page, :approval_status,:inquery
end