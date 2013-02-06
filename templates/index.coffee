@template = (req, res) ->
  @doctype 5
  @html ->
    @head ->
      @meta charset: 'utf-8'
      @title "sembly.net"
      @meta name: 'description', content: 'Copying could be a Right, if you want it.'
      @link rel: 'stylesheet', href: '/stylesheets/app.css'
      @script src: '/javascripts/jquery.js'
      @script src: '/javascripts/client.js'
      @script src: '/fonts/helvetiker.typeface.js'

    @body ->

      # see plugins/partials.coffee to see what this is about.
      # @partial '_fruitlist', ['apple', 'pear', 'banana']

      # Fork me on GitHub!
      # @a href:"https://github.com/jaekwon/sembly.net", ->
      #   @img style:"position: absolute; top: 0; right: 0; border: 0;", src:"https://s3.amazonaws.com/github/ribbons/forkme_right_red_aa0000.png", alt:"Fork me on GitHub"
