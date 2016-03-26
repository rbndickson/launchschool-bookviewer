require "tilt/erubis"
require "sinatra"
require "sinatra/reloader" if development?

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  
  erb :home
end

get "/chapters/:number" do
  chapter_number = params[:number]
  chapter_title = @contents[chapter_number.to_i - 1]
  @title = "Chapter #{@chapter_number}: #{chapter_title}"
  @chapter = File.read("data/chp#{chapter_number}.txt")

  erb :chapter
end

get "/search" do
  unless params.empty?
    query = params[:query]
    chapters = []
    12.times { |time| chapters << File.read("data/chp#{time + 1}.txt") }

    @paragraphs_with_query = []

    chapters.each_with_index do |chapter, chapter_index|
      chapter.split("\n\n").each_with_index do |paragraph, paragraph_index|
        if paragraph.include?(query)
          @paragraphs_with_query << {
            paragraph: paragraph,
            paragraph_index: paragraph_index,
            chapter_number: chapter_index + 1
          }
        end
      end
    end
  end

  erb :search
end

not_found do
  redirect "/"
end

helpers do
  def in_paragraphs(text)
    paragraphs = text.split("\n\n")
    paragraphs.each_with_index.inject('') do |sum, (paragraph_content, index)|
      sum + "<p id=paragraph_#{index}>#{paragraph_content}</p>"
    end
  end

  def highlight_queries(text, word)
    text.gsub(word, "<strong>#{word}</strong>")
  end
end
