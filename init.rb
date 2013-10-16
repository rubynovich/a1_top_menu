Redmine::Plugin.register :redmine_a1_top_menu do
  name 'Redmine A1 Top Menu plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  Rails.logger.error("  Setup a1 top-menu.".red)

  Redmine::MenuManager.map :top_menu do |menu| 

    # public_intercourse
    unless menu.exists?(:public_intercourse)
      menu.push(:public_intercourse, "#", 
                { :after => :home,
                  :parent => :top_menu, 
                  :caption => :label_public_intercourse_menu,
                  :if => Proc.new {

                    # redmine_contract_request
                    User.current.contract_request_manager? ||

                    # redmine_contacts - deals
                    User.current.allowed_to?({:controller => 'deals', :action => 'index'}, nil, {:global => true}) && RedmineContacts.settings[:show_deals_in_top_menu] ||

                    # redmine_contacts - contacts
                    User.current.allowed_to?({:controller => 'contacts', :action => 'index'}, nil, {:global => true}) 

                  }
                })
    end

    # internal_intercourse
    unless menu.exists?(:internal_intercourse)
      menu.push(:internal_intercourse, "#", 
                { :after => :public_intercourse,
                  :parent => :top_menu, 
                  :caption => :label_internal_intercourse_menu,
                  :if => Proc.new{

                    # redmine_meeting_rooms
                    User.current.allowed_to?({:controller => :meeting_room_reserves, :action => :index}, nil, {:global => true}) || 

                    # redmine_document_request
                    User.current.logged? ||
                    
                    # redmine_collegues
                    User.current.auth_source_id? || 

                    # redmine_people
                    User.current.allowed_people_to?(:view_people) 

                  }
                })
    end


    # projects
    menu.delete(:projects)
    menu.push(:projects, {:controller=>'projects', :action=>'index'}, 
              { :after => :internal_intercourse,
                :caption => :label_project_plural
              })

    # hr
    menu.push(:hr, "#", 
              { :after => :projects,
                :parent => :top_menu,
                :caption => :label_hr_menu,
                :if => Proc.new{ 

                  # redmine_delays
                  User.current.is_delays_manager?   ||
                  
                  # redmine_vacations
                  User.current.is_vacation_manager? || 

                  # redmine_hr 
                  User.current.is_hr?

                },
                :caption => :label_hr_menu
              })

    # workflow
    unless menu.exists?(:workflow)
      menu.push(:workflow, "#", 
                { :after => :internal_intercourse,
                  :parent => :top_menu, 
                  :caption => :label_workflow_menu,
                  :if => Proc.new{ 

                    # redmine_staff_request
                    User.current.staff_request_manager? ||

                    # redmine_planning
                    User.current.is_planning_manager?   ||  

                    # redmine_trips_journal
                    User.current.allowed_to?({:controller => :trips, :action => :index}, nil, {:global => true}) 
                  }
                })
    end

    menu.delete(:my_page)
    menu.push(:my_page, {:controller => :my, :action => :page}, 
              { :parent => :internal_intercourse })

  end

end
