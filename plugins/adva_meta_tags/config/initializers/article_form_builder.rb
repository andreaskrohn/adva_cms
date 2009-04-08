class ArticleFormBuilder < ExtensibleFormBuilder
  after :article, :tab_options do |f|
    tab :meta_tags do |f|
      <<-html
        <fieldset class="clearfix">
          <div class="col">
            #{ f.text_field(:meta_author, :label => true) }
            #{ f.text_field(:meta_geourl, :label => true) }
            #{ f.text_field(:meta_copyright, :label => true) }
          </div>
  
          <div class="col">
            #{ f.text_field(:meta_keywords, :label => true) }
            #{ f.text_area(:meta_description, :class => 'small', :label => true) }
          </div>
        </fieldset>
      html
    end
  end
end