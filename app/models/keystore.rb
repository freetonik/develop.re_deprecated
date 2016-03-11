class Keystore < ActiveRecord::Base
  validates_presence_of :key

  attr_accessible nil

  def self.get(key)
    self.where(:key => key).first
  end

  def self.put(key, value)
    if Keystore.connection.adapter_name == "SQLite"
      Keystore.connection.execute("INSERT OR REPLACE INTO " <<
        "#{Keystore.table_name} (key, value) VALUES " <<
        "(#{q(key)}, #{q(value)})")
    else
      Keystore.connection.execute("INSERT INTO #{Keystore.table_name} (" +
        "key, value) VALUES (#{q(key)}, #{q(value)})
        WHERE NOT EXISTS (SELECT 1 from #{Keystore.table_name} where key = #{q(key)})")

      Keystore.connection.execute("UPDATE #{Keystore.table_name} " +
        "SET value = #{q(value)} WHERE key = #{q(key)}")
    end

    true
  end

  def self.increment_value_for(key, amount = 1)
    self.incremented_value_for(key, amount)
  end

  def self.incremented_value_for(key, amount = 1)
    new_value = nil

    Keystore.transaction do
      if Keystore.connection.adapter_name == "SQLite"
        Keystore.connection.execute("INSERT OR IGNORE INTO " <<
          "#{Keystore.table_name} ('key', 'value') VALUES " <<
          "(#{q(key)}, 0)")
        Keystore.connection.execute("UPDATE #{Keystore.table_name} " <<
          "SET 'value' = 'value' + #{q(amount)} WHERE 'key' = #{q(key)}")
      else
        Keystore.connection.execute("INSERT INTO #{Keystore.table_name} (" +
          "key, value) VALUES (#{q(key)}, #{q(amount)})
          WHERE NOT EXISTS (SELECT 1 from #{Keystore.table_name} where key = #{q(key)})")

        Keystore.connection.execute("UPDATE #{Keystore.table_name} " +
          "SET value = value + #{q(amount)} WHERE key = #{q(key)}")
      end

      new_value = self.value_for(key)
    end

    return new_value
  end

  def self.decrement_value_for(key, amount = -1)
    self.increment_value_for(key, amount)
  end

  def self.decremented_value_for(key, amount = -1)
    self.incremented_value_for(key, amount)
  end

  def self.value_for(key)
    self.get(key).try(:value)
  end
end
