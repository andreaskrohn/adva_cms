require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class SectionsControllerTest < ActionController::TestCase
  with_common :a_section, :an_article
  
  describe "routing" do
    ['', '/a-section', '/de', '/de/a-section'].each do |path_prefix|
      ['', '/pages/2'].each do |path_suffix| 
        common = { :section_id => Section.first.id.to_s, :path_prefix => path_prefix, :path_suffix => path_suffix }
        common.merge! :locale => 'de' if path_prefix =~ /de/
        common.merge! :page => 2      if path_suffix =~ /pages/
      
        with_options common do |r|
          r.it_maps :get, '/',                         :action => 'show'
          r.it_maps :get, '/articles/an-article',      :action => 'show', :permalink => 'an-article'
          
          unless path_suffix =~ /pages/
            r.it_maps :get, '/articles/an-article.atom', :action => 'comments', :permalink => 'an-article', :format => 'atom'
          end
        end
      end
    end
    
    # these do not work with a root section path because there's a reguar Comments resource
    with_options :action => 'comments', :format => 'atom', :section_id => Section.first.id.to_s do |r|
      r.it_maps :get, '/a-section/comments.atom'
      r.it_maps :get, '/de/a-section/comments.atom', :locale => 'de'
    end
  end

  test "is a BaseController" do
    BaseController.should === @controller # FIXME matchy doesn't have a be_kind_of matcher
  end
  
  describe "GET to :show with no article permalink given" do
    action { get :show, params_from("/a-section") }
    
    with :the_article_is_published do
      it_assigns :section, :article
      it_renders :template, :show
      it_caches_the_page :track => '@article'
      
      it "assigns the section's primary article" do
        assigns(:article).should == @section.articles.primary
      end

      it "displays the article's body" do
        has_tag 'div[class~=entry]' do
          # FIXME not true in the default theme.
          # has_text @article.title 
          
          has_text @article.body
          
          # does not display a 'read more' link
          assert @response.body !~ /read the rest of this entry/i
          
          # FIXME currently not true
          # has_authorized_tag :a, /edit/i, :href => edit_admin_article_path(@site, @section, @article)

          # FIXME
          # lists the article's categories
          # lists the article's tags
        end
      end

      # FIXME
      # when article has an approved comment: shows the comment
      # when article has an unapproved comment: does not show any comments
      # when article does not have any comments: does not show any comments
      #
      # when article allows commenting: shows comment form 
      # when article does not allow commenting: does not show comment form 
    end
  end
    
  describe "GET to :show with an article permalink given" do
    action { get :show, params_from("/a-section/articles/a-section-article") }
    
    with :the_article_is_published do
      it_assigns :section, :article
      it_renders :template, :show
      it_caches_the_page :track => '@article'

      it "assigns the article referenced by the permalink" do
        assigns(:article).permalink.should == @article.permalink
      end
    end
    
    with :the_article_is_not_published do
      with :is_superuser do
        it_assigns :section, :article
        it_renders_template :show
        it_does_not_cache_the_page
      end
      
      with "the user may not update the article" do
        it_redirects_to { login_url(:return_to => @request.url) }
      end
    end
  end

  describe "GET to :comments with no article permalink given" do
    action { get :comments, params_from("/a-section/comments.atom") }

    with :the_article_is_published do
      it_assigns :section, :comments
      it_renders :template, 'comments/comments', :format => :atom
      
      # FIXME specify comments atom feed
    end
  end

  describe "GET to :comments with an article permalink given" do
    action { get :comments, params_from("/a-section/articles/a-section-article.atom") }

    with :the_article_is_published do
      it_assigns :section, :article, :comments
      it_renders :template, 'comments/comments', :format => :atom
      
      # FIXME specify comments atom feed
    end
  end
end