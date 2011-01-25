loop do
  Datum.transaction do
    Datum.connection.execute("SET TRANSACTION ISOLATION LEVEL SERIALIZABLE")

    begin
      if Datum.a.value > Datum.b.value
        puts "a.value=0 / b.value=1"
        Datum.a.update_attributes :value => 0
        Datum.b.update_attributes :value => 1
      else
        puts "a.value=1 / b.value=0"
        Datum.a.update_attributes :value => 1
        Datum.b.update_attributes :value => 0
      end

      @timeout_counter = Time.now # Reset the timeout counter
    rescue ActiveRecord::StatementInvalid => e
      @timeout_counter ||= Time.now # Set the timeout counter, if needed
      if Time.now - @timeout_counter > 30 #seconds
        # Give up after 30 seconds
        raise e
      else
        raise e unless e.message =~ /^PGError: ERROR:  could not serialize access due to concurrent update/
      end
    end
  end
end
