require 'rails_helper'

RSpec.describe 'Questions Import Integration', type: :feature do
  let(:sample_csv_path) { Rails.root.join('spec', 'fixtures', 'comprehensive_import_test.csv') }

  before do
    create_comprehensive_test_csv
  end

  describe 'Complete import workflow' do
    it 'successfully imports all question types' do
      visit import_questions_path

      # Verify the import page loads correctly
      expect(page).to have_content('Import Questions from CSV')
      expect(page).to have_content('CSV template')
      expect(page).to have_content('Supported Question Types')

      # Upload the CSV file
      attach_file('csv_file', sample_csv_path)
      check('preview_only')
      click_button('Import Questions')

      # Verify preview results
      expect(page).to have_content('Preview successful!')
      expect(page).to have_content('Questions Count: 11')

      # Complete the import
      click_button('Complete Import')

      # Verify redirect to questions index
      expect(current_path).to eq(questions_path)
      expect(page).to have_content('Import successful!')

      # Verify all questions were created
      expect(Question.count).to eq(11)
      expect(Topic.count).to eq(3) # Physics, Electronics, Programming
      expect(Source.count).to eq(2) # Feynman Lectures, Rails Guides

      # Verify specific question types
      expect(Question.where(question_type: 'written').count).to eq(3)
      expect(Question.where(question_type: 'multiple_choice').count).to eq(2)
      expect(Question.where(question_type: 'calculation').count).to eq(1)
      expect(Question.where(question_type: 'matching').count).to eq(1)
      expect(Question.where(question_type: 'cloze').count).to eq(1)
      expect(Question.where(question_type: 'ordering').count).to eq(1)
      expect(Question.where(question_type: 'ranking').count).to eq(1)
      expect(Question.where(question_type: 'diagram_label').count).to eq(1)
      expect(Question.where(question_type: 'composite').count).to eq(1)

      # Verify question content
      written_question = Question.find_by(content: 'Explain MOSFET operation')
      expect(written_question).to be_present
      expect(written_question.topic.name).to eq('Physics')
      expect(written_question.source.name).to eq('Feynman Lectures on Physics Vol. 2')
      expect(written_question.points).to eq(2)

      # Verify multiple choice question
      mc_question = Question.find_by(content: 'What does Ω represent?')
      expect(mc_question.options).to eq(['Ohms', 'Webers', 'Siemens', 'Tesla'])

      # Verify matching question
      matching_question = Question.find_by(content: 'Match each unit with its physical quantity.')
      expect(matching_question.options['left']).to eq(['Ohm (Ω)', 'Farad (F)', 'Henry (H)'])
      expect(matching_question.options['right']).to eq(['Inductance', 'Resistance', 'Capacitance'])

      # Verify diagram label question
      diagram_question = Question.find_by(content: 'Label the MOSFET terminals on the diagram.')
      expect(diagram_question.options['image']).to eq('MOSFET_N_Channel_symbol.svg')
      expect(diagram_question.options['labels']).to eq(['Gate', 'Source', 'Drain'])
      expect(diagram_question.options['markers']).to be_present

      # Verify composite question
      composite_question = Question.find_by(content: 'Answer the following about TOC.')
      expect(composite_question.options['parts']).to be_present
      expect(composite_question.options['parts'].length).to eq(3)
    end

    it 'handles validation errors gracefully' do
      # Create CSV with validation errors
      invalid_csv_path = Rails.root.join('spec', 'fixtures', 'invalid_import_test.csv')
      create_invalid_test_csv(invalid_csv_path)

      visit import_questions_path
      attach_file('csv_file', invalid_csv_path)
      check('preview_only')
      click_button('Import Questions')

      # Should show validation errors
      expect(page).to have_content('Validation failed:')
      expect(page).to have_content('Missing required field: topic')
      expect(page).to have_content('Invalid question_type')
    end

    it 'allows downloading the template' do
      visit import_questions_path
      
      # Click the template download link
      click_link('CSV template')
      
      # Verify the template file is served
      expect(response_headers['Content-Type']).to include('text/csv')
    end
  end

  describe 'Import with existing data' do
    before do
      # Create some existing data
      existing_topic = create(:topic, name: 'Physics')
      existing_source = create(:source, name: 'Feynman Lectures on Physics Vol. 2')
    end

    it 'reuses existing topics and sources' do
      visit import_questions_path
      attach_file('csv_file', sample_csv_path)
      click_button('Import Questions')

      # Should not create duplicate topics/sources
      expect(Topic.where(name: 'Physics').count).to eq(1)
      expect(Source.where(name: 'Feynman Lectures on Physics Vol. 2').count).to eq(1)
    end
  end

  private

  def create_comprehensive_test_csv
    csv_content = <<~CSV
      topic,question_type,content,answer,points,answer_size,source,source_reference,answer_label,unit,options,left_items,right_items,image,labels,markers,masks,parts
      Physics,written,"Explain MOSFET operation","High input impedance",2,short,Feynman Lectures on Physics Vol. 2,Ch 14,,,,,,,,,,
      Physics,written,"Describe amplitude modulation","AM varies carrier amplitude",1,short,,,,,,,,,,,,,
      Electronics,written,"Explain virtual earth","Inverting input held at 0V",2,short,Feynman Lectures on Physics Vol. 2,Ch 22,,,,,,,,,,
      Physics,calculation,"Calculate MOSFET threshold","0.25 MOhm",3,medium,Feynman Lectures on Physics Vol. 2,Ch 14,resistance,MOhm,,,,,,,,,
      Physics,multiple_choice,"What does Ω represent?","A - Ohms",1,short,,,,,"Ohms|Webers|Siemens|Tesla",,,,,,,
      Electronics,multiple_choice,"Which component stores energy?","B - Inductor",1,short,,,,,"Resistor|Inductor|Capacitor|Diode",,,,,,,
      Electronics,matching,"Match each unit with its physical quantity.","Ohm → Resistance",3,short,,,,,"Ohm (Ω)|Farad (F)|Henry (H)","Inductance|Resistance|Capacitance",,,,,,
      Physics,cloze,"In a MOSFET the gate is [[insulated]] from the channel.","insulated",2,short,,,,,,,,,,,,,
      Programming,ordering,"Place Rails request lifecycle in order.","Router → Controller → View",2,short,Rails Guides,Active Record,,,,,"Controller|View|Router",,,,,,
      Programming,ranking,"Rank caching layers by speed.","In-memory → Redis → Database",2,short,Rails Guides,Active Record,,,,,"Database|In-memory|Redis",,,,,,
      Electronics,diagram_label,"Label the MOSFET terminals on the diagram.","Gate Source Drain",2,short,Wikimedia Commons,MOSFET symbol,,,,,"MOSFET_N_Channel_symbol.svg","Gate|Source|Drain","[{""x"":26,""y"":35},{""x"":26,""y"":65},{""x"":75,""y"":50}]",,,
      Programming,composite,"Answer the following about Rails.","a) MVC; b) Strong params",5,medium,Rails Guides,Active Record,,,,,,,,"[{""type"":""written"",""content"":""a) Describe MVC"",""points"":2},{""type"":""multiple_choice"",""content"":""b) What are strong params?"",""options"":[""Security"",""Performance""],""points"":3}]",,
    CSV

    File.open(sample_csv_path, 'w') do |f|
      f.write(csv_content)
    end
  end

  def create_invalid_test_csv(file_path)
    csv_content = <<~CSV
      topic,question_type,content,answer,points,answer_size,source,source_reference,answer_label,unit,options,left_items,right_items,image,labels,markers,masks,parts
      ,written,"Test question?","Test answer",2,short,,,,,,,,,,,,,
      Physics,invalid_type,"Test question?","Test answer",2,short,,,,,,,,,,,,,
      Physics,written,"","Test answer",2,short,,,,,,,,,,,,,
      Physics,written,"Test question?","",2,short,,,,,,,,,,,,,
      Physics,written,"Test question?","Test answer",150,short,,,,,,,,,,,,,
      Physics,written,"Test question?","Test answer",2,invalid_size,,,,,,,,,,,,,
    CSV

    File.open(file_path, 'w') do |f|
      f.write(csv_content)
    end
  end
end
