/*
  # Add Indonesian Language and Lessons

  1. New Data
    - Add Indonesian language to languages table
    - Add Indonesian course
    - Add sample lessons for Indonesian language

  2. Content Structure
    - Basic Indonesian greetings and phrases
    - Multiple choice questions
    - Translation exercises
*/

-- Insert Indonesian language
INSERT INTO languages (name, code, flag_emoji, difficulty_level, total_lessons) VALUES
  ('Indonesian', 'id', '🇮🇩', 1, 20)
ON CONFLICT (code) DO NOTHING;

-- Insert Indonesian course
DO $$
DECLARE
    indonesian_language_id uuid;
BEGIN
    -- Get Indonesian language ID
    SELECT id INTO indonesian_language_id FROM languages WHERE code = 'id' LIMIT 1;
    
    IF indonesian_language_id IS NOT NULL THEN
        -- Insert Indonesian course
        INSERT INTO courses (language_id, title, description, difficulty_level, total_lessons, order_index)
        VALUES (
            indonesian_language_id,
            'Indonesian Basics',
            'Learn basic Indonesian vocabulary and conversation',
            1,
            20,
            1
        );
        
        -- Get the course ID for lessons
        DECLARE
            indonesian_course_id uuid;
        BEGIN
            SELECT id INTO indonesian_course_id FROM courses WHERE language_id = indonesian_language_id LIMIT 1;
            
            IF indonesian_course_id IS NOT NULL THEN
                -- Insert Indonesian lessons
                INSERT INTO lessons (course_id, title, description, lesson_type, content, order_index, xp_reward) VALUES
                (indonesian_course_id, 'Salam dan Sapaan', 'Belajar salam dan sapaan dasar dalam bahasa Indonesia', 'multiple-choice', '[
                    {
                        "type": "multiple-choice",
                        "question": "How do you say \"Hello\" in Indonesian?",
                        "options": ["Halo", "Selamat tinggal", "Terima kasih", "Tolong"],
                        "correct": "Halo"
                    },
                    {
                        "type": "multiple-choice",
                        "question": "What does \"Terima kasih\" mean?",
                        "options": ["Please", "Thank you", "Excuse me", "You are welcome"],
                        "correct": "Thank you"
                    },
                    {
                        "type": "translation",
                        "question": "Translate: \"Good morning\"",
                        "options": ["Selamat malam", "Selamat pagi", "Selamat siang", "Sampai jumpa"],
                        "correct": "Selamat pagi"
                    }
                ]'::jsonb, 1, 15),
                
                (indonesian_course_id, 'Angka 1-10', 'Belajar angka dalam bahasa Indonesia dari 1 sampai 10', 'multiple-choice', '[
                    {
                        "type": "multiple-choice",
                        "question": "How do you say \"five\" in Indonesian?",
                        "options": ["empat", "lima", "enam", "tujuh"],
                        "correct": "lima"
                    },
                    {
                        "type": "multiple-choice",
                        "question": "What number is \"delapan\"?",
                        "options": ["6", "7", "8", "9"],
                        "correct": "8"
                    },
                    {
                        "type": "translation",
                        "question": "Translate: \"three\"",
                        "options": ["dua", "tiga", "empat", "lima"],
                        "correct": "tiga"
                    }
                ]'::jsonb, 2, 15),
                
                (indonesian_course_id, 'Keluarga', 'Belajar nama-nama anggota keluarga dalam bahasa Indonesia', 'multiple-choice', '[
                    {
                        "type": "multiple-choice",
                        "question": "How do you say \"mother\" in Indonesian?",
                        "options": ["ayah", "ibu", "kakak", "adik"],
                        "correct": "ibu"
                    },
                    {
                        "type": "multiple-choice",
                        "question": "What does \"kakak\" mean?",
                        "options": ["younger sibling", "older sibling", "parent", "grandparent"],
                        "correct": "older sibling"
                    },
                    {
                        "type": "translation",
                        "question": "Translate: \"father\"",
                        "options": ["ibu", "ayah", "paman", "bibi"],
                        "correct": "ayah"
                    }
                ]'::jsonb, 3, 15),
                
                (indonesian_course_id, 'Makanan dan Minuman', 'Belajar nama makanan dan minuman dalam bahasa Indonesia', 'multiple-choice', '[
                    {
                        "type": "multiple-choice",
                        "question": "How do you say \"rice\" in Indonesian?",
                        "options": ["mie", "nasi", "roti", "sayur"],
                        "correct": "nasi"
                    },
                    {
                        "type": "multiple-choice",
                        "question": "What does \"air\" mean?",
                        "options": ["food", "water", "milk", "juice"],
                        "correct": "water"
                    },
                    {
                        "type": "translation",
                        "question": "Translate: \"coffee\"",
                        "options": ["teh", "kopi", "susu", "jus"],
                        "correct": "kopi"
                    }
                ]'::jsonb, 4, 15);
            END IF;
        END;
    END IF;
END $$;