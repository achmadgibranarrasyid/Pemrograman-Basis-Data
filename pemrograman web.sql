-- Bagian 2: Perintah-perintah SQL
-- a. Function
Function 1: Parameter Kosong


DELIMITER //

CREATE FUNCTION get_total_courses() RETURNS INT
BEGIN
    DECLARE total_courses INT;
    SELECT COUNT(*) INTO total_courses FROM Courses;
    RETURN total_courses;
END //

DELIMITER ;

-- eksekusi
-- Periksa fungsi yang dibuat
SHOW FUNCTION STATUS WHERE Db = 'OnlineCourseManagement';

-- Jalankan fungsi
SELECT get_total_courses();


-- Function 2: Dua Parameter

DELIMITER //

CREATE FUNCTION get_student_enrollments(in_student_id INT) RETURNS INT
BEGIN
    DECLARE total_enrollments INT;
    SELECT COUNT(*) INTO total_enrollments FROM Enrollments WHERE student_id = in_student_id;
    RETURN total_enrollments;
END //

DELIMITER ;

-- Eksekusi
SELECT get_student_enrollments(1);

-- Daftar Function
SHOW FUNCTION STATUS WHERE Db = 'library';
-- b. Procedure
Procedure 1: Parameter Kosong

DELIMITER //

CREATE PROCEDURE list_all_courses()
BEGIN
    SELECT * FROM Courses;
END //

DELIMITER ;

-- eksekusi
CALL list_all_courses();


-- Procedure 2: Dua Parameter dengan Control Flow
DELIMITER //

CREATE PROCEDURE add_new_student(IN p_name VARCHAR(255), IN p_email VARCHAR(255))
BEGIN
    DECLARE count INT;
    -- Menghitung jumlah siswa dengan email yang sama
    SELECT COUNT(*) INTO count FROM Students WHERE email = p_email;
    -- Memeriksa apakah email sudah ada
    IF count = 0 THEN
        -- Jika tidak ada, tambahkan siswa baru
        INSERT INTO Students (name, email) VALUES (p_name, p_email);
    ELSE
        -- Jika ada, perbarui nama siswa yang sudah ada
        UPDATE Students SET name = p_name WHERE email = p_email;
    END IF;
END //

DELIMITER ;
CALL add_new_student('John Doe', 'john.doe@mail.com');


-- Eksekusi dan Daftar Procedure

-- Eksekusi
CALL list_all_books();
CALL add_new_member('New Member', 'newmember@mail.com');

-- Daftar Procedure
SHOW PROCEDURE STATUS WHERE Db = 'library';

-- c. Trigger
-- 6 Buah Trigger

-- BEFORE INSERT
CREATE TRIGGER before_insert_books BEFORE INSERT ON Books
FOR EACH ROW SET NEW.genre = UPPER(NEW.genre);

-- BEFORE UPDATE
CREATE TRIGGER before_update_books BEFORE UPDATE ON Books
FOR EACH ROW SET NEW.genre = UPPER(NEW.genre);

-- BEFORE DELETE
CREATE TRIGGER before_delete_books BEFORE DELETE ON Books
FOR EACH ROW BEGIN
    INSERT INTO log_table(action, book_id, date) VALUES ('DELETE', OLD.book_id, NOW());
END;

-- AFTER INSERT
CREATE TRIGGER after_insert_books AFTER INSERT ON Books
FOR EACH ROW BEGIN
    INSERT INTO log_table(action, book_id, date) VALUES ('INSERT', NEW.book_id, NOW());
END;

-- AFTER UPDATE
CREATE TRIGGER after_update_books AFTER UPDATE ON Books
FOR EACH ROW BEGIN
    INSERT INTO log_table(action, book_id, date) VALUES ('UPDATE', NEW.book_id, NOW());
END;

-- AFTER DELETE
CREATE TRIGGER after_delete_books AFTER DELETE ON Books
FOR EACH ROW BEGIN
    INSERT INTO log_table(action, book_id, date) VALUES ('DELETE', OLD.book_id, NOW());
END;

-- Eksekusi dan Daftar Trigger

-- Eksekusi (Contoh: Menambahkan Buku Baru)
INSERT INTO Books (title, author, published_year, genre) VALUES ('New Book', 'New Author', 2024, 'new genre');

-- Daftar Trigger
SHOW TRIGGERS;
-- d. Index
-- 3 Buah Index

-- Membuat Tabel Baru
CREATE TABLE new_books (
    id INT,
    title VARCHAR(255),
    author VARCHAR(255),
    PRIMARY KEY (id, author)
);

-- Membuat Index dengan CREATE INDEX
CREATE INDEX idx_title_author ON Books (title, author);

-- Membuat Index dengan ALTER TABLE
ALTER TABLE Members ADD INDEX idx_name_email (name, email);

-- Daftar Index

SHOW INDEX FROM Books;
SHOW INDEX FROM Members;
SHOW INDEX FROM new_books;

-- e. View
-- 3 Buah View

-- Horizontal View
CREATE VIEW view_books AS SELECT title, author FROM Books;

-- Vertical View
CREATE VIEW view_members AS SELECT name, email FROM Members;

-- View inside View
CREATE VIEW detailed_view_books AS SELECT * FROM view_books WITH CHECK OPTION;

-- Eksekusi dan Daftar View

-- Eksekusi Update dan Insert
INSERT INTO view_books (title, author) VALUES ('Inserted Book', 'Inserted Author');
UPDATE view_books SET author = 'Updated Author' WHERE title = 'Inserted Book';

-- Daftar View
SHOW FULL TABLES IN library WHERE TABLE_TYPE LIKE 'VIEW';

-- f. Database Security
-- Membuat User dan Role

-- User Baru
CREATE USER 'user1'@'localhost' IDENTIFIED BY 'password1';
CREATE USER 'user2'@'localhost' IDENTIFIED BY 'password2';
CREATE USER 'user3'@'localhost' IDENTIFIED BY 'password3';

-- Role Baru
CREATE ROLE finance;
CREATE ROLE human_dev;
CREATE ROLE warehouse;

-- Memberikan Privilege
GRANT SELECT ON library.Books TO 'user1'@'localhost';
GRANT SELECT ON library.view_members TO 'user2'@'localhost';
GRANT EXECUTE ON PROCEDURE library.add_new_member TO finance;

-- Eksekusi dan Verifikasi Privilege

-- Eksekusi sebagai User1
-- (Masuk sebagai user1 dan coba akses tabel Books)
SELECT * FROM library.Books;

-- Eksekusi sebagai User2
-- (Masuk sebagai user2 dan coba akses view view_members)
SELECT * FROM library.view_members;

-- Eksekusi sebagai Role finance
-- (Menambahkan user ke dalam role finance dan mencoba eksekusi procedure)
GRANT finance TO 'user3'@'localhost';
CALL library.add_new_member('Role Member', 'rolemember@mail.com');