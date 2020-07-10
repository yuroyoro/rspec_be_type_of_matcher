RSpec.describe BeTypeOfMatcher do
  subject {
    m = be_type_of(expected_type)
    m = m.or_nil if or_nil
    expect(value).to m
  }

  let(:value)         { nil } # actual value
  let(:expected_type) { nil } # expected_type that is given to be_kind_of matcher
  let(:or_nil)        { false }

  # failure_message pattern
  let(:message) {
    "expected #{value.inspect} to be type of #{expected_type.inspect}#{ or_nil ? " or nil" : ""}"
  }

  shared_examples "pass" do
    it {
      expect{ subject }.to_not raise_error
    }
  end

  shared_examples "fail" do
    it {
      expect{ subject }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /#{Regexp.escape message}/)
    }
  end

  describe "type pattern" do
    let(:value)         { "foo" }
    let(:expected_type) { String }

    context "when actual value is match expected type" do
      it_behaves_like "pass"
    end

    context "when actual value is not match expected type" do
      let(:expected_type) { Symbol }

      it_behaves_like "fail"
    end

    context "when actual value is nil" do
      let(:value) { nil }

      it_behaves_like "fail"
    end

    context "when given matcher to expected_type" do
      context "and value matches given matcher" do
        let(:expected_type) { be_kind_of(String) }

        it_behaves_like "pass"
      end

      context "and value does not match given matcher" do
        let(:expected_type) { be_kind_of(Symbol) }
        let(:message)       { "expected #{value.inspect} to be a kind of Symbol" }

        it_behaves_like "fail"
      end
    end
  end

  describe "allow nil value" do
    let(:value)         { "foo" }
    let(:expected_type) { String }
    let(:or_nil)        { true }

    context "when actual value is match expected type" do
      it_behaves_like "pass"
    end

    context "when actual value is not match expected type" do
      let(:expected_type) { Symbol }

      it_behaves_like "fail"
    end

    context "when actual value is nil" do
      let(:value) { nil }

      it_behaves_like "pass"

      context "when given matcher to expected_type" do
        it_behaves_like "pass"
      end
    end
  end

  describe "or pattern" do
    subject {
      expect(value).to be_type_of(*expected_types)
    }

    let(:value)          { "foo" }
    let(:expected_types) { [String, Symbol] }
    let(:expected_type)  { expected_types.join(" or ") }

    context "when actual value type is included in expected types" do
      it_behaves_like "pass"
    end

    context "when actual value type is not included in expected types" do
      let(:expected_types) { [Integer, Array] }

      it_behaves_like "fail"
    end

    context "when actual value is nil" do
      let(:value) { nil }

      it_behaves_like "fail"
    end
  end

  describe "boolean pattern" do
    let(:expected_type) { :boolean }

    context "when actual value type is TrueClass" do
      let(:value) { true }

      it_behaves_like "pass"
    end

    context "when actual value type is FalseClass" do
      let(:value) { false }

      it_behaves_like "pass"
    end

    context "when actual value type is not TrueClass or FalseClass" do
      let(:value) { :foo }

      it_behaves_like "fail"
    end

    context "when actual value is nil" do
      let(:value) { nil }

      it_behaves_like "fail"
    end
  end

  describe "array pattern" do
    let(:value)         { ["foo", "bar"] }
    let(:expected_type) { [String] }

    context "when actual value is not Array" do
      let(:value) { { foo: 1 } }

      it_behaves_like "fail"
    end

    context "when actual value is Array" do
      context "and includes value that is not expected_type" do
        let(:value) { ["foo", "bar", 1] }

        it_behaves_like "fail"
      end

      context "and all included value is expected_type" do
        it_behaves_like "pass"
      end
    end

    context "when actual value is Enumerable" do
      context "and includes value that is not expected_type" do
        let(:value) { ["foo", "bar", 1].each }

        it_behaves_like "fail"
      end

      context "and all included values are expected_type" do
        let(:value) { ["foo", "bar"].each }

        it_behaves_like "pass"
      end
    end

    context "when given array of matcher to expected_type" do
      let(:expected_type) { [be_kind_of(String)] }

      context "and includes value that does not match given matcher" do
        let(:value) { ["foo", "bar", 1] }

        it_behaves_like "fail"
      end

      context "and all included values match given matcher" do
        it_behaves_like "pass"
      end
    end

    context "when given array of be_type_of matcher to expected_type" do
      let(:expected_type) { [be_type_of(String, Integer)] }

      context "and includes value that does not match given matcher" do
        let(:value) { ["foo", "bar", :bar] }

        it_behaves_like "fail"
      end

      context "and all included values match given matcher" do
        let(:value) { ["foo", "bar", 1] }

        it_behaves_like "pass"
      end
    end
  end

  describe "hash pattern" do
    let(:value)         { { foo: 1, bar: 2 } }
    let(:expected_type) { { Symbol => Integer } }

    context "when actual value is not Hash" do
      let(:value) { ["foo", "bar", 1] }

      it_behaves_like "fail"
    end

    context "when actual value is Hash" do
      context "and includes key that is not expected_type" do
        let(:value) { { foo: 1, bar: 2, "baz" => 3 } }

        it_behaves_like "fail"
      end

      context "and includes value that is not expected_type" do
        let(:value) { { foo: 1, bar: 2, baz: "aaa" } }

        it_behaves_like "fail"
      end

      context "and all included keys and values are expected_type" do
        it_behaves_like "pass"
      end
    end

    context "when given matcher to expected_type's key" do
      let(:expected_type) { { be_type_of(String, Symbol) => Integer } }

      context "and includes key that does not match given matcher" do
        let(:value) { { foo: 1, bar: 2, "baz" => 3, 99 => 4 } }

        it_behaves_like "fail"
      end

      context "and all included keys match given matcher" do
        let(:value) { { foo: 1, bar: 2, "baz" => 3 } }

        it_behaves_like "pass"
      end
    end

    context "when given matcher to expected_type's value" do
      let(:expected_type) { { Symbol => be_type_of(Integer, String) } }

      context "and includes value that does not match given matcher" do
        let(:value) { { foo: 1, bar: 2, baz: :aaa } }

        it_behaves_like "fail"
      end

      context "and all included value matches given matcher" do
        let(:value) { { foo: 1, bar: 2, baz: "aaa" } }

        it_behaves_like "pass"
      end
    end
  end

  describe "complex pattern" do
    context "array patten in hash key" do
      let(:expected_type) { { [Symbol] => String } }

      context "actual value matches given pattern" do
        let(:value) {
          {
            [:foo, :bar] => "baz",
            [:aaa, :bbb] => "ccc",
          }
        }

        it_behaves_like "pass"
      end

      context "actual value does not match given pattern" do
        let(:value) {
          {
            [:foo, :bar]  => "baz",
            [:aaa, "bbb"] => "ccc",
          }
        }

        it_behaves_like "fail"
      end
    end

    context "array patten in hash value" do
      let(:expected_type) { { Symbol => [String] } }

      context "actual value matches given pattern" do
        let(:value) {
          {
            foo: ["bar", "baz"],
            aaa: ["bbb", "ccc"],
          }
        }

        it_behaves_like "pass"
      end

      context "actual value does not match given pattern" do
        let(:value) {
          {
            foo: ["bar", "baz"],
            aaa: ["bbb", :ccc],
          }
        }

        it_behaves_like "fail"
      end
    end

    context "hash pattern in array" do
      let(:expected_type) { [{ Symbol => String }] }

      context "actual value matches given pattern" do
        let(:value) {
          [
            { foo:  "bar",  aaa: "bbb" },
            { hoge: "fuga", ccc: "ddd" },
          ]
        }

        it_behaves_like "pass"
      end

      context "actual value does not match given pattern" do
        let(:value) {
          [
            { foo:  "bar",  aaa: "bbb" },
            { hoge: "fuga", ccc: :ddd },
          ]
        }

        it_behaves_like "fail"
      end
    end

    context "hash pattern with array of matcher in array" do
      let(:expected_type) { [{ Symbol => [be_kind_of(String)] }] }

      context "actual value matches given pattern" do
        let(:value) {
          [
            { foo:  ["bar", "baz"],   aaa: ["bbb", "ccc"] },
            { hoge: ["fuga", "hige"], ccc: ["ddd", "eee"] },
          ]
        }

        it_behaves_like "pass"
      end

      context "actual value does not match given pattern" do
        let(:value) {
          [
            { foo:  ["bar", "baz"],   aaa: ["bbb", "ccc"] },
            { hoge: ["fuga", "hige"], ccc: ["ddd", :eee] },
          ]
        }

        it_behaves_like "fail"
      end
    end
  end

  context "when invalid patten given" do
    let(:value) { "foo" }

    context "when given array that have too many element" do
      let(:expected_type) { [String, Symbol] }

      let(:message) { "expcted type of array must have exactly 1 element" }

      it_behaves_like "fail"
    end

    context "when given hash that have too many entry" do
      let(:expected_type) { { String => Integer, Symbol => Integer } }

      let(:message) { "expcted type of hash must have exactly 1 entry" }

      it_behaves_like "fail"
    end

    context "invalid type definition in array" do
      let(:value)         { [{ foo: 1 }] }
      let(:expected_type) { [{ String => Integer, Symbol => Integer }] }
      let(:message)       { "expcted type of hash must have exactly 1 entry" }

      it_behaves_like "fail"
    end

    context "invalid type definition in hash key" do
      let(:value)         { { [1] => "foo" } }
      let(:expected_type) { { [Integer, Symbol] => String } }
      let(:message)       { "expcted type of array must have exactly 1 element" }

      it_behaves_like "fail"
    end

    context "invalid type definition in hash value" do
      let(:value)         { { "foo" => [1] } }
      let(:expected_type) { { String => [Integer, Symbol] } }
      let(:message)       { "expcted type of array must have exactly 1 element" }

      it_behaves_like "fail"
    end
  end
end
