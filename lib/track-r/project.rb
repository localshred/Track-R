# Container for project's attributes.
# Receives a hash with either :project key pointing to an hpricot object or a
# project_id and a token with which to fetch and build the project object
class Project
  attr_reader :name, :iteration_length, :id, :week_start_day, :point_scale, :api_url, :url, :token, :meta
  
  def initialize(options = {})
    @token   = options[:token] || Token.new
    if options.include?(:project_id)
      @id      = options[:project_id]
      @api_url = "#{CONFIG[:api_location]}/projects/#{@id}"
      @url     = "#{CONFIG[:site_location]}/projects/#{@id}"
      @project = Hpricot(open(@api_url, {"X-TrackerToken" => @token.to_s}))
      @stories = nil
    elsif options.include?(:project)
      @project = options[:project]
    else
      raise ArgumentError, "Valid options are: :project (receives an Hpricot Object) OR :project_id + :token"
    end
    build_project
  end
  
  # Builds an array containing the project's stories
  def stories ; @stories || get_stories ; end
  
  def iterations ; @iterations || get_iterations ; end
  
  # Fetches a story with given id
  def story(id)
    Story.new(:story_id => id, :project_id => @id, :token => @token.to_s)
  end
  
  # Creates a story for this project. Receives a set of valid attributes.
  # Returns a Story object
  # TODO: Validate attributes
  def create_story(attributes = {})
    api_url = URI.parse("#{CONFIG[:api_location]}/projects/#{@id}/stories")
    query_string = attributes.map { |key, value| "story[#{key}]=#{CGI::escape(value)}"}.join('&')
    response = Net::HTTP.start(api_url.host, api_url.port) do |http|
      http.post(api_url.path, query_string.concat("&token=#{@token.to_s}"))
    end
  
    story = (Hpricot(response.body)/:story)
    Story.new(:story => story, :project_id => @id, :token => @token.to_s)
  end
  
  # Deletes a story given a Story object or a story_id
  def delete_story(story)
    if story.is_a?(Story)
      api_url = URI.parse("#{CONFIG[:api_location]}/projects/#{@id}/stories/#{story.id}")
    elsif story.is_a?(Integer) || story.to_i.is_a?(Integer)
      api_url = URI.parse("#{CONFIG[:api_location]}/projects/#{@id}/stories/#{story}")
    else
      raise ArgumentError, "Should receive a story id or a Story object."
    end
    response = Net::HTTP.start(api_url.host, api_url.port) do |http|
      http.delete(api_url.path, {"X-TrackerToken" => @token.to_s})
    end
    story = (Hpricot(response.body)/:story)
    Story.new(:story => story, :project_id => @id, :token => @token.to_s)
  end
  
  def get_iterations(iteration_type=nil)
    @iterations = Iteration.find(:project_id => @id, :type => iteration_type) || []
  end
  
  # Gets the stories for a given iteration
  def get_iteration_stories(iteration_type=nil)
    @stories = get_iterations(iteration_type).stories
  end
  
  def num_stories
    stories.size || 0
  end
  
  def num_completed_stories
    num_completed_stories = 0
    stories.each do |story|
      num_completed_stories += 1 if completed_statuses.include?(story.current_state)
    end
    num_completed_stories
  end
  
  def current_target_date
    get_iterations.last.finish_date
  end
  
  def completed_statuses
    %w{ finished delivered accepted }
  end
  
  # Builds an array containing the project's stories
  protected
  
  # Builds a project given an hpricot object stored at instance variable
  # @project
  def build_project
    @id               ||= @project.at('id').inner_html
    @api_url          ||= "#{CONFIG[:api_location]}/projects/#{@id}"
    @url              ||= "http://www.pivotaltracker.com/projects/#{@id}"
    @name             = @project.at('name').inner_html
    @iteration_length = @project.at('iteration_length').inner_html
    @week_start_day   = @project.at('week_start_day').inner_html
    @point_scale      = @project.at('point_scale').inner_html.split(',')
    @meta             = ProjectMeta.find_by_project_id(@id)
    if @meta.nil?
      init_meta
    else
      @meta.sync(self)
    end
  end
  
  def get_stories
    api_url = "#{CONFIG[:api_location]}/projects/#{@id}/stories"
    @stories = (Hpricot(open(api_url, {"X-TrackerToken" => @token.to_s}))/:story).map {|story| Story.new(:story => story, :project_id => @id)}
  end
  
  def init_meta
    @meta = ProjectMeta.create_from_project(self)
  end

end