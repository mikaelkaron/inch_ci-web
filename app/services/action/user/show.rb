require 'inch_ci/action'

module Action
  module User
    class Show
      include InchCI::Action

      LANGUAGES = %w(Ruby Elixir JavaScript)
      DEFAULT_TAB = LANGUAGES.first

      exposes :user, :projects, :projects_without_badges, :languages,
              :active_tab

      def initialize(current_user, params)
        if user = find_user(params)
          @user = UserPresenter.new(user)
          @languages = LANGUAGES
          @projects = find_projects(@user) #.map { |p| ProjectPresenter.new(p) }
          @projects_without_badges = @projects.select do |project|
            project.language == 'Ruby' &&
              project.default_branch.try(:latest_revision_id).nil?
          end
          @active_tab = params[:tab] || DEFAULT_TAB
        else
          raise "Not found: #{params}"
        end
      end

      private

      def find_user(params)
        InchCI::Store::FindUser.call(params[:service], params[:user])
      end

      def find_projects(user)
        InchCI::Store::FindAllProjects.call(user).select(&:name)
      end
    end
  end
end
