require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id

  def initialize(id = nil, name, grade)
    @id = id 
    @name = name 
    @grade = grade
  end

  def self.create_table
    create_students = <<-SQL 
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
      SQL
    DB[:conn].execute(create_students)
  end

  def self.drop_table
    drop_students = 'DROP TABLE IF EXISTS students'
    DB[:conn].execute(drop_students)
  end

  def save
    if self.id
      self.update
    else
      insert_students = <<-SQL 
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(insert_students, self.name, self.grade)
      select_last = 'SELECT last_insert_rowid() FROM students'
      @id = DB[:conn].execute(select_last)[0][0]
    end
  end

  def self.create(name, grade)
    Student.new(name, grade).tap do |student|
      student.save
    end
  end

  def self.new_from_db(record)
    id = record[0]
    name = record[1]
    grade = record[2]
    self.new(id, name, grade)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = 'UPDATE students SET name = ?, grade = ? WHERE id = ?'
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
