require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton
  
  def initialize
    super('aaquestions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Replies
  attr_accessor :body, :question_id, :author_id, :parent_reply_id
  
  def self.find_by_user_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        replies
      WHERE
        author_id = ?
    SQL
    Replies.new(data.first)
  end
  
  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    Replies.new(data.first)
  end
  
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    Replies.new(data.first)
  end
  
  def initialize(options)
    @id = options['id'] #1 #2
    @body = options['body'] #'What's your quesiton #Answer my question
    @question_id = options['question_id'] #1 #1
    @author_id = options['author_id'] #1 #2
    @parent_reply_id = options['parent_reply_id'] #null #1
  end
  
  def author
    data = QuestionsDatabase.instance.execute(<<-SQL, @author_id)
      SELECT
        fname, lname
      FROM
        users
      WHERE
        id = ?
    SQL
    "#{data.first['fname']} #{data.first['lname']}"
  end
  
  def question
    data = QuestionsDatabase.instance.execute(<<-SQL, @question_id)
      SELECT
        body
      FROM
        questions
      WHERE
        id = ?
    SQL
    "#{data.first['body']}"
  end
  
  def parent_reply
    raise "I have no parents" if @parent_reply_id.nil?
    data = QuestionsDatabase.instance.execute(<<-SQL, parent_reply_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.id = ?
    SQL
    "#{data.first['body']}"
  end
  
  def child_reply
    "#{@body}"
  end
end

class QuestionFollows
  attr_accessor :question_id, :user_id
  
  def self.followers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, fname, lname
      FROM
        users
      JOIN
        question_follows
        ON
          question_follows.user_id = users.id
      WHERE
        question_follows.question_id = ?
    SQL
    data.map { |datum| Users.new(datum) }
  end
  
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    QuestionFollows.new(data.first)
  end
  
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end
end

class QuestionLikes
  attr_accessor :question_id, :user_id
  
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    QuestionLikes.new(data.first)
  end
  
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end
end

class Questions
  attr_accessor :title, :body, :author_id
  
  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    Questions.new(data.first)
  end
  
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    Questions.new(data.first)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end
  
  def author
    data = QuestionsDatabase.instance.execute(<<-SQL, @author_id)
      SELECT
        fname, lname
      FROM
        users
      WHERE
        id = ?
    SQL
    "#{data.first['fname']} #{data.first['lname']}"
  end
  
  def replies
    "#{Replies.find_by_question_id(@id).body}"
  end
end

class Users
  attr_accessor :fname, :lname
  
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    Users.new(data.first)
  end
  
  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    Users.new(data.first)
  end
  
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
  
  def authored_questions
    Questions.find_by_author_id(@id)
  end
  
  def authored_replies
    Reply.find_by_user_id(@id)
  end
end