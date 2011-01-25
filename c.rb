loopno = 0

loop do
  Datum.transaction do
    Datum.connection.execute("SET TRANSACTION ISOLATION LEVEL SERIALIZABLE")

    a, b = Datum.a, Datum.b

    delta = (b.value - a.value).abs

    abort("not isolated: a.value=#{ a.value } / b.value=#{ b.value }") if delta != 1

    puts loopno += 1
  end
end
