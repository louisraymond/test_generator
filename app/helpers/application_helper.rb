module ApplicationHelper
  def question_type_description(type)
    descriptions = {
      'written' => 'Open-ended text questions',
      'multiple_choice' => 'Questions with multiple answer choices',
      'calculation' => 'Mathematical problems requiring calculations',
      'matching' => 'Match items from two columns',
      'cloze' => 'Fill-in-the-blank questions',
      'ordering' => 'Arrange items in correct sequence',
      'ranking' => 'Rank items by priority or importance',
      'diagram_label' => 'Label parts of a diagram',
      'image_occlusion' => 'Identify hidden parts of an image',
      'composite' => 'Multi-part questions with different types',
      'markdown' => 'Questions with markdown formatting'
    }
    descriptions[type] || 'Question type'
  end
end
