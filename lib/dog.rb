
class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id:nil, name:, breed:)
    @id, @name, @breed = id, name, breed
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
     sql = "INSERT INTO dogs(name, breed) VALUES(?, ?);"
     DB[:conn].execute(sql, self.name, self.breed)
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
   self
  end

  def self.create(dog_hash)
    new_dog = Dog.new(dog_hash)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    dog_a = DB[:conn].execute(sql, id).flatten
    dog_hash = {id: dog_a[0], name: dog_a[1], breed: dog_a[2]}
    new_dog = Dog.new(dog_hash)
  end

  def self.find_or_create_by(dog_hash)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    name = dog_hash[:name]
    breed = dog_hash[:breed]
    dog_a = DB[:conn].execute(sql, name, breed).flatten
    if !dog_a.empty?
      new_dog = Dog.new_from_db(dog_a)
    else
      new_dog = Dog.create(dog_hash)
    end
    new_dog
  end

  def self.new_from_db(row)
    dog_hash = {id: row[0], name: row[1], breed: row[2]}
    new_dog = self.create(dog_hash)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    dog_a = DB[:conn].execute(sql, name).flatten
    dog_hash = {id: dog_a[0], name: dog_a[1], breed: dog_a[2]}
    self.find_or_create_by(dog_hash)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
