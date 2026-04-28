module QueryCounter
  IGNORED = [/\A(BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE SAVEPOINT)/i, /SCHEMA/].freeze

  def self.count_for
    queries = []
    callback = ->(_name, _start, _finish, _id, payload) do
      sql = payload[:sql]
      next if payload[:name] == 'SCHEMA'
      next if IGNORED.any? { |re| sql =~ re }
      queries << sql
    end
    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
      yield
    end
    queries.size
  end
end
