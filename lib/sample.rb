# typed: true

require 'sorbet-runtime'

# config

# sigに.checkedを指定してない場合にruntimeでの型チェックを実行するかどうか :always(default) :tests :never
# ただし、これで抑制できるのは call_validation_error だけ
# 環境変数 SORBET_RUNTIME_DEFAULT_CHECKED_LEVEL でも設定可能
T::Configuration.default_checked_level = :always

# .checked(:tests)を指定している場合も通常のsigと同じに扱うかどうか
# 環境変数 SORBET_RUNTIME_ENABLE_CHECKING_IN_TESTS でも設定可能
T::Configuration.enable_checking_for_sigs_marked_checked_tests

# T.let, cast, must, assert_type! で間違った変換をしている場合（inline type assertions）のエラーハンドリング
T::Configuration.inline_type_error_handler = lambda do |error, opts|
  puts "\n--- inline_type_error_handler ---\n#{error.message}\n"
end

# sig と実際の値が合わない場合（invalid method calls）のエラーハンドリング
T::Configuration.call_validation_error_handler = lambda do |signature, opts|
  puts "\n--- call_validation_error_handler ---\n#{opts[:pretty_message]}\n"
end

# sigのproc{}部分returnsやvoidを指定していないなどの文法ミスがあった場合（invalid sig procs）のエラーハンドリング
T::Configuration.sig_builder_error_handler = lambda do |error, location|
  puts "\n--- sig_builder_error_handler ---\n#{error.message}\n"
end

# sig自体の文法は正しいが、overrideやabstractの指定と実態が異なる場合（invalid sigs）のエラーハンドリング
T::Configuration.sig_validation_error_handler = lambda do |error, opts|
  puts "\n--- sig_validation_error_handler ---\n#{error.message}\n"
end

# code

class Sample
  extend T::Sig

  # T.letでStringの値をIntegerに変換しようとしている
  # -> inline_type_error_handler
  sig { params(num: Integer).returns(Integer) }
  def a(num)
    T.let('string', Integer)
    1
  end

  # sig内でStringを返すと指定しているが、実際はIntegerが返ってくる
  # -> call_validation_error
  sig { params(num: Integer).returns(String) }
  def b(num)
    1
  end

  # sig内のprocで.returnsや.voidを指定してない
  # -> sig_builder_error_handler
  sig { params(num: Integer) }
  def c(num)
    1
  end

  # .overrideと書いているが、実際はoverrideしていない
  # -> sig_validation_error_handler
  sig { params(num: Integer).override.returns(Integer) }
  def d(num)
    1
  end
end

Sample.new.a(1)
Sample.new.b(1)
Sample.new.c(1)
Sample.new.d(1)
