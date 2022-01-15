class Meal < ActiveRecord::Base
    def self.list
        Meal.all
    end
end
