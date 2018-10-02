module Imdb
  class Theatre
    class DefaultSchedule
      def self.schedule
        Proc.new do
          hall :blue, title: 'Синий зал', places: 50
          hall :green, title: 'Зелёный зал (deluxe)', places: 12
          hall :red, title: 'Красный зал', places: 100

          period '09:00'..'19:00' do
            description "Morning"
            filters  period: :ancient
            price 3
            hall :red
          end

          period '12:00'..'17:00' do
            description "Afternoon"
            filters  genre: %w[Comedy Adventure]
            price 5
            hall :blue
          end

          period '18:00'..'23:00' do
            description "Evening"
            filters  genre: %w[Drama Horror]
            price 10
            hall :green
          end
        end
      end
    end
  end
end
