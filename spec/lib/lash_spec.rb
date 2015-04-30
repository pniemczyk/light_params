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
    object_factory(params: source, real_class_name: 'Test') do
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
    let(:source) { person_source }

    it '#first_name returns same value as [:first_name]' do
      expect(subject.first_name).to eq(subject[:first_name])
      expect(subject.first_name).to eq(source[:first_name])
    end
  end

  describe 'ability to transform value before being assigned' do
    let(:source) { person_source }
    it '#age returns as int by transformation' do
      expect(subject.age).to eq(source[:age].to_i)
    end
  end
  describe 'ability to assign to key from other name of key' do
  end
  describe 'ability to set default value when value is not present' do
  end
  describe 'ability to get value from string or symbol key' do
  end
  describe 'ability to make uniq collecion' do
  end
  describe 'ability to clear collection from nil values' do
  end
  describe 'ability to clear collection from empty values' do
  end
  describe 'ability to validate values' do
  end
  describe 'ability to make instance for defined class from value' do
  end
  describe '.from_json' do
  end
  describe '#to_json' do
  end
  describe '#as_json' do
  end
end
