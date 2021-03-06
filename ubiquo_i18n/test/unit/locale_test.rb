require File.dirname(__FILE__) + "/../test_helper.rb"

class Ubiquo::LocaleTest < ActiveSupport::TestCase

  def teardown
    Locale.current = nil
    Locale.use_fallbacks = nil
  end

  def test_should_create_locale
    assert_difference 'Locale.count' do
      locale = create_locale
      assert !locale.new_record?, "#{locale.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_iso_code
    assert_no_difference 'Locale.count' do
      l = create_locale(:iso_code => nil)
      assert l.errors[:iso_code]
    end
  end

  def test_should_require_unique_iso_code
    assert_difference 'Locale.count', 1 do
      l = create_locale(:iso_code => "my_code")
      assert !l.new_record?

      l = create_locale(:iso_code => "my_code")
      assert l.errors[:iso_code]

      l = create_locale(:iso_code => "MY_CODE")
      assert l.errors[:iso_code]
    end
  end

  def test_should_store_current_locale
    Locale.current = 'ca'
    assert_equal 'ca', Locale.current
  end

  def test_should_store_current_locale_as_symbol
    Locale.current = :ca
    assert_equal :ca, Locale.current
  end

  def test_humanized_name_capitalizes_native_name
    locale = create_locale
    locale.expects(:native_name).returns('result')
    assert_equal 'Result', locale.humanized_name
  end

  def test_should_cache_find_by_iso_code
    Locale.clear_cache
    Locale.expects(:active).once.returns([])
    2.times { Locale.find_by_iso_code('ca') }
  end

  def test_should_use_fallback_attribute
    assert !Locale.use_fallbacks
    Locale.use_fallbacks = true
    assert Locale.use_fallbacks
    Locale.use_fallbacks = false
    assert !Locale.use_fallbacks
  end

  def test_fallbacks_method_should_use_i18n_and_add_all
    I18n.fallbacks = I18n::Locale::Fallbacks.new(:my_lang => :my_other)
    assert_equal [:my_lang, :my_other, :all], Locale.fallbacks('my_lang')
  end

end
