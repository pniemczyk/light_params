describe LightParams::Lash do
  let(:person_source) do
    {
      first_name: 'Pawel',
      laste_name: 'Niemczyk',
      age: '30',
      created_at: '1983-09-07T18:37:52+02:00',
      children: children_source
    }
  end

  let(:children_source) { [first_child_source, last_child_source] }

  let(:first_child_source) do
    {
      first_name: 'Emilia',
      laste_name: 'Niemczyk',
      age: '4',
      created_at: '2011-02-11T18:37:52+02:00'
    }
  end

  let(:last_child_source) do
    {
      first_name: 'Tomasz',
      laste_name: 'Niemczyk',
      age: '2',
      created_at: '2012-06-27T18:37:52+02:00'
    }
  end

  subject do
    object_factory(params: source) do
      properties :first_name, :laste_name
      property :age, with: -> (v) { v.to_i }
      property :created_at, with: :to_date
      property :children, collection: true do
        properties :first_name, :laste_name
        property :age, with: -> (v) { v.to_i }
        property :created_at, with: :to_date
      end

      private

      def to_date(value)
        DateTime.parse(value)
      end
    end
  end

  describe 'ability to use method instead of []' do
    subject do
      object_factory(params: source) do
        properties :first_name, :laste_name
      end
    end

    let(:source) { person_source }

    it '#first_name returns same value as [:first_name]' do
      expect(subject.first_name).to eq(subject[:first_name])
      expect(subject.first_name).to eq(source[:first_name])
    end
  end

  describe 'ability to transform value before being assigned' do
    subject do
      object_factory(params: source) do
        properties :first_name, :laste_name, with: -> (v) { v.to_i }
        property :age, with: -> (v) { v.to_i }
        property :created_at, with: :to_date
        property :children, collection: true do
          property :age, with: -> (v) { v.to_i }
          property :created_at, with: :to_date
        end

        private

        def to_date(value)
          DateTime.parse(value)
        end
      end
    end


    let(:source) { person_source }

    it '#age returns as int by transformation' do
      expect(subject.first_name).to eq(0)
      expect(subject.laste_name).to eq(0)
      expect(subject.age).to eq(source[:age].to_i)
      expect(subject.created_at).to eq(DateTime.parse(source[:created_at]))
      expect(subject.children.first.age).to eq(source[:children].first[:age].to_i)
      expect(subject.children.first.created_at).to eq(DateTime.parse(source[:children].first[:created_at]))
    end
  end

  describe 'ability to assign to key from other name of key' do
    subject do
      object_factory(params: source) do
        property :name, from: :first_name
      end
    end

    let(:source) { person_source }

    it '#name returns as [:first_name] by using from option' do
      expect(subject.name).to eq(source[:first_name])
    end
  end

  describe 'ability to set default value when value is not present' do
    subject do
      object_factory(params: source) do
        property :name, default: 'Andrzej'
      end
    end

    let(:source) { {} }

    it '#name returns Andrzej by using default option' do
      expect(subject.name).to eq('Andrzej')
    end
  end

  describe 'ability to make uniq collecion' do
    subject do
      object_factory(params: source) do
        property :children, collection: true, uniq: true
      end
    end

    let(:source) do
      {
        children: [
          first_child_source,
          first_child_source,
          last_child_source,
          last_child_source
        ]
      }
    end

    it '#children are returned as uniq' do
      expect(subject.children.count).to eq(2)
      expect(subject.children.first.first_name).to eq(first_child_source[:first_name])
      expect(subject.children.last.first_name).to eq(last_child_source[:first_name])
    end
  end

  describe 'ability to clear collection from nil values' do
    subject do
      object_factory(params: source) do
        property :children, collection: true, compact: true
      end
    end

    let(:source) do
      {
        children: [
          first_child_source,
          nil,
          nil,
          last_child_source
        ]
      }
    end

    it '#children are returned as compact' do
      expect(subject.children.count).to eq(2)
      expect(subject.children.first.first_name).to eq(first_child_source[:first_name])
      expect(subject.children.last.first_name).to eq(last_child_source[:first_name])
    end
  end

  describe 'ability to make instance for defined class from value' do
    class Child
      attr_accessor :first_name, :laste_name, :age, :created_at
      def initialize(attrs = {})
        attrs.each { |k, v| send("#{k}=", v) }
      end
    end

    subject do
      object_factory(params: source) do
        property :child, model: Child
        property :children, collection: Child
      end
    end

    let(:source) do
      {
        child: first_child_source,
        children: [
          first_child_source,
          last_child_source
        ]
      }
    end

    it '#children are returned as compact' do
      expect(subject.child).to be_kind_of(Child)
      expect(subject.child.first_name).to eq(first_child_source[:first_name])
      expect(subject.children.count).to eq(2)
      expect(subject.children.first).to be_kind_of(Child)
      expect(subject.children.last).to be_kind_of(Child)
      expect(subject.children.first.first_name).to eq(first_child_source[:first_name])
      expect(subject.children.last.first_name).to eq(last_child_source[:first_name])
    end
  end

  describe 'ability to validate values' do
  end

  describe '.from_json' do
    subject do
      class_factory do
        properties :first_name, :laste_name, :age, :created_at
      end
    end

    it 'returns instance of lash' do
      test_obj = subject.from_json(first_child_source.to_json)
      expect(test_obj).to be_kind_of(described_class)
      expect(test_obj.first_name).to eq(first_child_source[:first_name])
    end

    it 'raise JsonParseError when parsing fail' do
      expect { subject.from_json('abc') }.to raise_error(LightParams::Errors::JsonParseError)
    end
  end

  describe '#to_json' do
    subject do
      object_factory(params: first_child_source) do
        properties :first_name, :laste_name
        property :age, with: -> (v) { v.to_i }
        property :created_at, with: -> (v) { DateTime.parse(v) }
      end
    end

    it 'returns json' do
      expect(subject.to_json).to eq(
        '{"first_name":"Emilia","laste_name":"Niemczyk","age":4,"created_at":"2011-02-11T18:37:52.000+02:00"}'
      )
    end
  end

  describe '#as_json' do
    subject do
      object_factory(params: first_child_source) do
        properties :first_name, :laste_name
        property :age, with: -> (v) { v.to_i }
        property :created_at, with: -> (v) { DateTime.parse(v) }
      end
    end

    it 'returns json' do
      expect(subject.as_json).to eq(
        first_child_source.merge(
          age: first_child_source[:age].to_i,
          created_at: DateTime.parse(first_child_source[:created_at])
        )
      )
    end
  end
end
