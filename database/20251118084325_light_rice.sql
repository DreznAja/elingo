/*
  # Add Sample Lessons for All Courses

  1. New Data
    - Add sample lessons for each course
    - Include proper lesson content with questions
    - Set appropriate XP rewards and order

  2. Content Structure
    - Multiple choice questions
    - Translation exercises
    - Vocabulary practice
*/

-- Insert sample lessons for all courses
DO $$
DECLARE
    spanish_course_id uuid;
    french_course_id uuid;
    japanese_course_id uuid;
    german_course_id uuid;
    italian_course_id uuid;
    portuguese_course_id uuid;
BEGIN
    -- Get course IDs
    SELECT c.id INTO spanish_course_id FROM courses c JOIN languages l ON c.language_id = l.id WHERE l.code = 'es' LIMIT 1;
    SELECT c.id INTO french_course_id FROM courses c JOIN languages l ON c.language_id = l.id WHERE l.code = 'fr' LIMIT 1;
    SELECT c.id INTO japanese_course_id FROM courses c JOIN languages l ON c.language_id = l.id WHERE l.code = 'ja' LIMIT 1;
    SELECT c.id INTO german_course_id FROM courses c JOIN languages l ON c.language_id = l.id WHERE l.code = 'de' LIMIT 1;
    SELECT c.id INTO italian_course_id FROM courses c JOIN languages l ON c.language_id = l.id WHERE l.code = 'it' LIMIT 1;
    SELECT c.id INTO portuguese_course_id FROM courses c JOIN languages l ON c.language_id = l.id WHERE l.code = 'pt' LIMIT 1;

    -- Spanish lessons
    IF spanish_course_id IS NOT NULL THEN
        INSERT INTO lessons (course_id, title, description, lesson_type, content, order_index, xp_reward) VALUES
        (spanish_course_id, 'Basic Greetings', 'Learn common Spanish greetings', 'multiple-choice', '[
            {
                "type": "multiple-choice",
                "question": "How do you say \"Hello\" in Spanish?",
                "options": ["Hola", "Adiós", "Gracias", "Por favor"],
                "correct": "Hola"
            },
            {
                "type": "multiple-choice",
                "question": "What does \"Gracias\" mean?",
                "options": ["Please", "Thank you", "Excuse me", "You are welcome"],
                "correct": "Thank you"
            },
            {
                "type": "translation",
                "question": "Translate: \"Good morning\"",
                "options": ["Buenas noches", "Buenos días", "Buenas tardes", "Hasta luego"],
                "correct": "Buenos días"
            }
        ]'::jsonb, 1, 15),
        (spanish_course_id, 'Numbers 1-10', 'Learn Spanish numbers from 1 to 10', 'multiple-choice', '[
            {
                "type": "multiple-choice",
                "question": "How do you say \"five\" in Spanish?",
                "options": ["cuatro", "cinco", "seis", "siete"],
                "correct": "cinco"
            },
            {
                "type": "multiple-choice",
                "question": "What number is \"ocho\"?",
                "options": ["6", "7", "8", "9"],
                "correct": "8"
            },
            {
                "type": "translation",
                "question": "Translate: \"three\"",
                "options": ["dos", "tres", "cuatro", "cinco"],
                "correct": "tres"
            }
        ]'::jsonb, 2, 15);
    END IF;

    -- French lessons
    IF french_course_id IS NOT NULL THEN
        INSERT INTO lessons (course_id, title, description, lesson_type, content, order_index, xp_reward) VALUES
        (french_course_id, 'French Basics', 'Learn basic French phrases', 'multiple-choice', '[
            {
                "type": "multiple-choice",
                "question": "How do you say \"Hello\" in French?",
                "options": ["Bonjour", "Au revoir", "Merci", "S''il vous plaît"],
                "correct": "Bonjour"
            },
            {
                "type": "multiple-choice",
                "question": "What does \"Merci\" mean?",
                "options": ["Please", "Thank you", "Excuse me", "You are welcome"],
                "correct": "Thank you"
            },
            {
                "type": "translation",
                "question": "Translate: \"Good evening\"",
                "options": ["Bon matin", "Bonsoir", "Bonne nuit", "À bientôt"],
                "correct": "Bonsoir"
            }
        ]'::jsonb, 1, 15);
    END IF;

    -- Japanese lessons
    IF japanese_course_id IS NOT NULL THEN
        INSERT INTO lessons (course_id, title, description, lesson_type, content, order_index, xp_reward) VALUES
        (japanese_course_id, 'Japanese Greetings', 'Learn basic Japanese greetings', 'multiple-choice', '[
            {
                "type": "multiple-choice",
                "question": "How do you say \"Hello\" in Japanese?",
                "options": ["Konnichiwa", "Sayonara", "Arigato", "Sumimasen"],
                "correct": "Konnichiwa"
            },
            {
                "type": "multiple-choice",
                "question": "What does \"Arigato\" mean?",
                "options": ["Please", "Thank you", "Excuse me", "You are welcome"],
                "correct": "Thank you"
            },
            {
                "type": "translation",
                "question": "Translate: \"Good morning\"",
                "options": ["Konbanwa", "Ohayo gozaimasu", "Oyasumi", "Mata ashita"],
                "correct": "Ohayo gozaimasu"
            }
        ]'::jsonb, 1, 15);
    END IF;

    -- German lessons
    IF german_course_id IS NOT NULL THEN
        INSERT INTO lessons (course_id, title, description, lesson_type, content, order_index, xp_reward) VALUES
        (german_course_id, 'German Basics', 'Learn basic German phrases', 'multiple-choice', '[
            {
                "type": "multiple-choice",
                "question": "How do you say \"Hello\" in German?",
                "options": ["Hallo", "Auf Wiedersehen", "Danke", "Bitte"],
                "correct": "Hallo"
            },
            {
                "type": "multiple-choice",
                "question": "What does \"Danke\" mean?",
                "options": ["Please", "Thank you", "Excuse me", "You are welcome"],
                "correct": "Thank you"
            },
            {
                "type": "translation",
                "question": "Translate: \"Good morning\"",
                "options": ["Gute Nacht", "Guten Morgen", "Guten Abend", "Bis später"],
                "correct": "Guten Morgen"
            }
        ]'::jsonb, 1, 15);
    END IF;

    -- Italian lessons
    IF italian_course_id IS NOT NULL THEN
        INSERT INTO lessons (course_id, title, description, lesson_type, content, order_index, xp_reward) VALUES
        (italian_course_id, 'Italian Basics', 'Learn basic Italian phrases', 'multiple-choice', '[
            {
                "type": "multiple-choice",
                "question": "How do you say \"Hello\" in Italian?",
                "options": ["Ciao", "Arrivederci", "Grazie", "Prego"],
                "correct": "Ciao"
            },
            {
                "type": "multiple-choice",
                "question": "What does \"Grazie\" mean?",
                "options": ["Please", "Thank you", "Excuse me", "You are welcome"],
                "correct": "Thank you"
            },
            {
                "type": "translation",
                "question": "Translate: \"Good morning\"",
                "options": ["Buona notte", "Buongiorno", "Buona sera", "A dopo"],
                "correct": "Buongiorno"
            }
        ]'::jsonb, 1, 15);
    END IF;

    -- Portuguese lessons
    IF portuguese_course_id IS NOT NULL THEN
        INSERT INTO lessons (course_id, title, description, lesson_type, content, order_index, xp_reward) VALUES
        (portuguese_course_id, 'Portuguese Basics', 'Learn basic Portuguese phrases', 'multiple-choice', '[
            {
                "type": "multiple-choice",
                "question": "How do you say \"Hello\" in Portuguese?",
                "options": ["Olá", "Tchau", "Obrigado", "Por favor"],
                "correct": "Olá"
            },
            {
                "type": "multiple-choice",
                "question": "What does \"Obrigado\" mean?",
                "options": ["Please", "Thank you", "Excuse me", "You are welcome"],
                "correct": "Thank you"
            },
            {
                "type": "translation",
                "question": "Translate: \"Good morning\"",
                "options": ["Boa noite", "Bom dia", "Boa tarde", "Até logo"],
                "correct": "Bom dia"
            }
        ]'::jsonb, 1, 15);
    END IF;

END $$;