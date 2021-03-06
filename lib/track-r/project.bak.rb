# Container for project's attributes.
# Receives a hash with either :project key pointing to an hpricot object or a
# project_id and a token with which to fetch and build the project object
class Project
  attr_reader :name, :iteration_length, :id, :week_start_day, :point_scale,
    :api_url, :url, :token

  def initialize(options = {})
    if options.include?(:project_id)
      @id      = options[:project_id]
      @token   = options[:token].to_s || CONFIG[:api_token]
      @api_url = "#{CONFIG[:api_location]}/projects/#{@id}"
      @url     = "#{CONFIG[:site_location]}/projects/#{@id}"
      @project = Hpricot(open(@api_url, {"X-TrackerToken" => @token}))
      @stories = nil
    elsif options.include?(:project)
      @project = options[:project]
    else
      raise ArgumentError, "Valid options are: :project (receives an Hpricot Object) OR :project_id + :token"
    end
    build_project
  end

  # Builds an array containing the project's story
  def stories ; @stories || get_stories ; end

  # Fetches a story with given id
  def story(id)
    Story.new(:story_id => id, :project_id => @id, :token => @token)
  end

  # Creates a story for this project. Receives a set of valid attributes.
  # Returns a Story object
  # TODO: Validate attributes
  def create_story(attributes = {})
    api_url = URI.parse("#{CONFIG[:api_location]}/projects/#{@id}/stories")
    query_string = attributes.map { |key, value| "story[#{key}]=#{CGI::escape(value)}"}.join('&')
    response = Net::HTTP.start(api_url.host, api_url.port) do |http|
      http.post(api_url.path, query_string.concat("&token=#{@token}"))
    end

    story = (Hpricot(response.body)/:story)
    Story.new(:story => story, :project_id => @id, :token => @token)
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
      http.delete(api_url.path, {"X-TrackerToken" => @token})
    end
    story = (Hpricot(response.body)/:story)
    Story.new(:story => story, :project_id => @id, :token => @token)
  end

  def get_iterations(iteration_type=nil)
    Iteration.find(:project_id => @id, :type => type)
  end

  # Gets the stories for a given iteration
  def get_iteration_stories(iteration_type=nil)
    get_iterations(type).stories
  end

  # Gets the current iteration's stories
  # def current_stories
    # get_stories_by_iteration("current")
  # end

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
  end

  # Builds an array containing the project's stories
  def get_stories
    api_url = "#{CONFIG[:api_location]}/projects/#{@id}/stories"
    @stories = (Hpricot(open(api_url, {"X-TrackerToken" => @token.to_s}))/:story).map {|story| Story.new(:story => story, :project_id => @id, :token => @token)}
  end

  # Builds an array containing the project's stories for a given iteration
  # def get_stories_by_iteration(name)
  #   api_url = "#{CONFIG[:api_location]}/projects/#{@id}/iterations/#{name}"
  #   @stories = (Hpricot(open(api_url, {"X-TrackerToken" => @token.to_s}))/:story).map {|story| Story.new(:story => story, :project_id => @id, :token => @token)}
  # end

end # class Tracker::Project
