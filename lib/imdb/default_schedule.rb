module Imdb
  class Theatre
    class Schedule
      def self.default
        proc do
          hall :blue, title: 'Синий зал', places: 50
          hall :green, title: 'Зелёный зал (deluxe)', places: 12
          hall :red, title: 'Красный зал', places: 100

          period '09:00'..'19:00' do
            description 'Morning'
            pattern period: :ancient
            price 300
            hall :red
          end

          period '12:00'..'17:00' do
            description 'Afternoon'
            pattern genre: %w[Comedy Adventure]
            price 500
            hall :blue
          end

          period '18:00'..'23:00' do
            description 'Evening'
            pattern genre: %w[Drama Horror]
            price 1000
            hall :green
          end
        end
      end
    end
  end
end
