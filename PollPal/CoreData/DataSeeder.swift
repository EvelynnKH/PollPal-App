//
//  DataSeeder.swift
//  PollPal
//
//  Created by student on 03/12/25.
//

import CoreData
import Foundation

struct DataSeeder {
    static func seed(viewContext: NSManagedObjectContext) {
        // 1. Cek apakah database sudah ada isinya?
        if isDatabaseEmpty(viewContext: viewContext) {
            print("Database kosong. Memulai seeding data...")
            createData(viewContext: viewContext)
        } else {
            print("Data sudah ada. Skip seeding.")
        }
    }

    private static func isDatabaseEmpty(viewContext: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<Survey> = Survey.fetchRequest()
        do {
            let count = try viewContext.count(for: fetchRequest)
            return count == 0
        } catch {
            return true  // Jika error, anggap kosong biar aman
        }
    }

    private static func createData(viewContext: NSManagedObjectContext) {

        // --- Helpers untuk Tanggal ---
        let calendar = Calendar.current
        let today = Date()
        // Deadline 7 hari ke depan
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today)
        // Deadline 3 hari ke depan
        let threeDaysLater = calendar.date(byAdding: .day, value: 3, to: today)
        // Lahir 20 tahun lalu
        let birthDateUser = calendar.date(byAdding: .year, value: -20, to: today)

        // --- CATEGORY ---
        let catTech = Category(context: viewContext)
        catTech.category_id = UUID()
        catTech.category_name = "Technology"

        let catDaily = Category(context: viewContext)
        catDaily.category_id = UUID()
        catDaily.category_name = "Daily Life"

        let catHealth = Category(context: viewContext)
        catHealth.category_id = UUID()
        catHealth.category_name = "Health"

        let catGaming = Category(context: viewContext)
        catGaming.category_id = UUID()
        catGaming.category_name = "Gaming"

        // --- USER 1: FELICIA ---
        let felicia = User(context: viewContext)
        felicia.user_id = UUID()
        felicia.user_name = "Felicia Kathrin"
        felicia.user_email = "feli@gmail.com"
        felicia.user_pwd = "feli123"
        felicia.user_point = 100
        felicia.user_header_img = "mountain"
        felicia.user_profile_img = "cat"
        felicia.user_created_at = today
        felicia.user_status_del = false
        
        // Atribut Baru User
        felicia.user_birthdate = birthDateUser
        felicia.user_birthplace = "Surabaya"
        felicia.user_residence = "Citraland, Surabaya"
        felicia.user_gender = "Female"
        felicia.user_hp = "081234567890"
        // felicia.user_ktm_img = Data() // Jika punya data dummy, masukkan disini

        felicia.addToLike_category(catTech)
        felicia.addToLike_category(catDaily)

        // --- USER 2: EVELIN (CREATOR) ---
        let userCreator = User(context: viewContext)
        userCreator.user_id = UUID()
        userCreator.user_name = "Evelin"  // Nama Owner
        userCreator.user_email = "evelin@pollpal.com"
        userCreator.user_pwd = "evelin123"
        userCreator.user_header_img = "mountain"
        userCreator.user_profile_img = "cat"
        userCreator.user_point = 500
        userCreator.user_created_at = today
        userCreator.user_status_del = false
        
        // Atribut Baru User
        userCreator.user_birthdate = calendar.date(byAdding: .year, value: -22, to: today)
        userCreator.user_birthplace = "Jakarta"
        userCreator.user_residence = "UC Apartment"
        userCreator.user_gender = "Female"
        userCreator.user_hp = "089876543211"

        // --- SURVEY 1: TECH ---
        let survey1 = Survey(context: viewContext)
        survey1.survey_id = UUID()
        survey1.survey_title = "Penggunaan AI Mahasiswa"
        survey1.survey_description = "Seberapa sering mahasiswa menggunakan ChatGPT untuk tugas?"
        survey1.survey_points = 50
        survey1.survey_rewards_points = 250
        survey1.survey_created_at = today
        survey1.is_public = true
        survey1.survey_updated_at = today
        survey1.survey_status_del = false
        survey1.owned_by_user = userCreator
        
        // Atribut Baru Survey
        survey1.survey_deadline = nextWeek // 7 hari lagi
        survey1.survey_img_url = "survey_ai_illustration" // Nama aset gambar dummy
        survey1.survey_target_responden = 100
        
        // Kriteria Responden
        survey1.survey_usia_min = 18
        survey1.survey_usia_max = 25
        survey1.survey_gender = "All"
        survey1.survey_birthplace = "All"
        survey1.survey_residence = "All"

        // Relasi Category (Many-to-Many)
        survey1.addToHas_category(catTech)

        // Tambah Dummy Question
        let q1 = Question(context: viewContext)
        q1.question_id = UUID()
        q1.question_text = "Apakah kamu pakai ChatGPT?"
        q1.question_type = "Multiple Choice"
        q1.question_price = 10
        q1.question_status_del = false
        q1.in_survey = survey1

        // Option
        let opt1_yes = addOption(to: q1, text: "Ya, Sering", context: viewContext)
        let opt1_no = addOption(to: q1, text: "Tidak Pernah", context: viewContext)

        let q2 = Question(context: viewContext)
        q2.question_id = UUID()
        q2.question_text = "Ceritakan pengalamanmu!"
        q2.question_type = "Long Answer"
        q2.question_price = 10
        q2.question_status_del = false
        q2.in_survey = survey1

        // --- SURVEY 2: HEALTH ---
        let survey2 = Survey(context: viewContext)
        survey2.survey_id = UUID()
        survey2.survey_title = "Pola Tidur & Gadget"
        survey2.survey_description = "Hubungan main HP sebelum tidur dengan kualitas tidur."
        survey2.survey_points = 50
        survey2.survey_rewards_points = 250
        survey2.survey_created_at = today
        survey2.is_public = true
        survey2.survey_updated_at = today
        survey2.survey_status_del = false
        survey2.owned_by_user = felicia
        
        // Atribut Baru Survey
        survey2.survey_deadline = threeDaysLater // 3 hari lagi
        survey2.survey_img_url = "survey_sleep"
        survey2.survey_target_responden = 50
        
        // Kriteria
        survey2.survey_usia_min = 15
        survey2.survey_usia_max = 60
        survey2.survey_gender = "All"
        survey2.survey_birthplace = "All"
        survey2.survey_residence = "Surabaya" // Target spesifik lokasi

        survey2.addToHas_category(catHealth)
        survey2.addToHas_category(catTech)

        let q4 = Question(context: viewContext)
        q4.question_id = UUID()
        q4.question_text = "Jam berapa kamu tidur?"
        q4.question_type = "Multiple Choice"
        q4.question_price = 10
        q4.question_status_del = false
        q4.in_survey = survey2

        addOption(to: q4, text: "< 10 Malam", context: viewContext)
        addOption(to: q4, text: "> 12 Malam", context: viewContext)

        let q5 = Question(context: viewContext)
        q5.question_id = UUID()
        q5.question_text = "Apakah main HP di kasur?"
        q5.question_type = "Multiple Choice"
        q5.question_price = 10
        q5.question_status_del = false
        q5.in_survey = survey2

        // --- SURVEY 3: KANTIN ---
        let survey3 = Survey(context: viewContext)
        survey3.survey_id = UUID()
        survey3.survey_title = "Evaluasi Kantin UC"
        survey3.survey_description = "Survey kepuasan pelanggan kantin lantai 1"
        survey3.survey_points = 50
        survey3.survey_rewards_points = 20
        survey3.is_public = true
        survey3.survey_created_at = today
        survey3.survey_updated_at = today
        survey3.survey_status_del = false
        survey3.owned_by_user = felicia
        
        // Atribut Baru Survey
        survey3.survey_deadline = calendar.date(byAdding: .month, value: 1, to: today) // 1 bulan lagi
        survey3.survey_img_url = "survey_food"
        survey3.survey_target_responden = 200
        
        survey3.survey_usia_min = 17
        survey3.survey_usia_max = 30
        survey3.survey_gender = "All"
        survey3.survey_birthplace = "All"
        survey3.survey_residence = "UC Apartment"

        survey3.addToHas_category(catDaily)

        let q6 = Question(context: viewContext)
        q6.question_id = UUID()
        q6.question_text = "Apakah kamu setuju makanannya enak?"
        q6.question_type = "Short Answer"
        q6.question_price = 1
        q6.question_status_del = false
        q6.in_survey = survey3 // Perbaikan: Sebelumnya survey1, harusnya survey3

        // --- RESPONSES & TRANSACTIONS (Tetap Sama, disesuaikan sedikit) ---
        let hRes = HResponse(context: viewContext)
        hRes.hresponse_id = UUID()
        hRes.submitted_at = today
        hRes.in_survey = survey1
        hRes.is_filled_by_user = felicia

        let dRes1 = DResponse(context: viewContext)
        dRes1.dresponse_id = UUID()
        dRes1.in_hresponse = hRes
        dRes1.in_question = q1
        dRes1.has_option = NSSet(array: [opt1_yes])
        dRes1.dresponse_answer_text = opt1_yes.option_text

        let dRes2 = DResponse(context: viewContext)
        dRes2.dresponse_id = UUID()
        dRes2.in_hresponse = hRes
        dRes2.in_question = q2
        dRes2.dresponse_answer_text = "Sangat membantu tugas coding saya."

        // Transactions
        let trans = Transaction(context: viewContext)
        trans.transaction_id = UUID()
        trans.transaction_point_change = 1000
        trans.transaction_description = "Top Up Berhasil"
        trans.transaction_status_del = false
        trans.owned_by_user = felicia
        trans.transaction_created_at = calendar.date(byAdding: .day, value: -1, to: today)
        trans.transaction_type = "TOP UP"

        let trans2 = Transaction(context: viewContext)
        trans2.transaction_id = UUID()
        trans2.transaction_point_change = 50
        trans2.transaction_description = "Reward Survey: Kepuasan Customer"
        trans2.transaction_status_del = false
        trans2.owned_by_user = felicia
        trans2.in_survey = survey1
        trans2.transaction_created_at = calendar.date(byAdding: .hour, value: -5, to: today)
        trans2.transaction_type = "REWARD SURVEY"

        let trans3 = Transaction(context: viewContext)
        trans3.transaction_id = UUID()
        trans3.transaction_point_change = -1000
        trans3.transaction_description = "Survey Cost: Riset Pasar Produk Baru"
        trans3.transaction_status_del = false
        trans3.owned_by_user = felicia
        trans3.in_survey = survey2
        trans3.transaction_created_at = calendar.date(byAdding: .day, value: -3, to: today)
        trans3.transaction_type = "COST SURVEY"

        let trans4 = Transaction(context: viewContext)
        trans4.transaction_id = UUID()
        trans4.transaction_point_change = -500
        trans4.transaction_description = "Withdraw Points"
        trans4.transaction_status_del = false
        trans4.owned_by_user = felicia
        trans4.transaction_created_at = calendar.date(byAdding: .hour, value: -2, to: today)
        trans4.transaction_type = "WITHDRAW"

        // --- SURVEY DEMO (Baru) ---
        let surveyDemo = Survey(context: viewContext)
        surveyDemo.survey_id = UUID()
        surveyDemo.survey_title = "Survey Kepuasan Karyawan"
        surveyDemo.survey_description = "Demo semua tipe soal: Pilihan Ganda, Isian, Kotak Centang, dll."
        surveyDemo.survey_points = 100
        surveyDemo.survey_rewards_points = 500
        surveyDemo.survey_created_at = today
        surveyDemo.is_public = true
        surveyDemo.survey_status_del = false
        surveyDemo.owned_by_user = userCreator
        
        // Atribut Baru
        surveyDemo.survey_deadline = calendar.date(byAdding: .day, value: 30, to: today)
        surveyDemo.survey_img_url = "survey_office"
        surveyDemo.survey_target_responden = 500
        surveyDemo.survey_usia_min = 20
        surveyDemo.survey_usia_max = 55
        surveyDemo.survey_gender = "All"
        surveyDemo.survey_birthplace = "All"
        surveyDemo.survey_residence = "All"

        surveyDemo.addToHas_category(catDaily)

        // Q1: Multiple Choice
        let qMc = Question(context: viewContext)
        qMc.question_id = UUID()
        qMc.question_text = "Divisi apa tempat anda bekerja?"
        qMc.question_type = "Multiple Choice"
        qMc.question_price = 10
        qMc.question_status_del = false
        qMc.in_survey = surveyDemo

        addOption(to: qMc, text: "Marketing", context: viewContext)
        addOption(to: qMc, text: "IT / Tech", context: viewContext)
        addOption(to: qMc, text: "HRD", context: viewContext)

        // Q2: Short Answer
        let qShort = Question(context: viewContext)
        qShort.question_id = UUID()
        qShort.question_text = "Siapa nama manajer langsung anda?"
        qShort.question_type = "Short Answer"
        qShort.question_price = 10
        qShort.question_status_del = false
        qShort.in_survey = surveyDemo

        // Q3: Paragraph
        let qPara = Question(context: viewContext)
        qPara.question_id = UUID()
        qPara.question_text = "Jelaskan kendala terbesar anda saat bekerja di kantor ini?"
        qPara.question_type = "Paragraph"
        qPara.question_price = 15
        qPara.question_status_del = false
        qPara.in_survey = surveyDemo

        // Q4: Check Box
        let qCheck = Question(context: viewContext)
        qCheck.question_id = UUID()
        qCheck.question_text = "Fasilitas apa yang sering anda gunakan? (Pilih semua yang sesuai)"
        qCheck.question_type = "Check Box"
        qCheck.question_price = 10
        qCheck.question_status_del = false
        qCheck.in_survey = surveyDemo

        addOption(to: qCheck, text: "Kantin", context: viewContext)
        addOption(to: qCheck, text: "Gym", context: viewContext)
        addOption(to: qCheck, text: "Ruang Meeting", context: viewContext)
        addOption(to: qCheck, text: "Area Parkir", context: viewContext)

        // Q5: Drop Down
        let qDrop = Question(context: viewContext)
        qDrop.question_id = UUID()
        qDrop.question_text = "Berapa lama anda sudah bekerja disini?"
        qDrop.question_type = "Drop Down"
        qDrop.question_price = 10
        qDrop.question_status_del = false
        qDrop.in_survey = surveyDemo

        addOption(to: qDrop, text: "< 1 Tahun", context: viewContext)
        addOption(to: qDrop, text: "1 - 3 Tahun", context: viewContext)
        addOption(to: qDrop, text: "> 3 Tahun", context: viewContext)

        // Q6: Linear Scale
        let qScale = Question(context: viewContext)
        qScale.question_id = UUID()
        qScale.question_text = "Seberapa puas anda dengan gaji saat ini? (1 = Kecewa, 5 = Sangat Puas)"
        qScale.question_type = "Linear Scale"
        qScale.question_price = 10
        qScale.question_status_del = false
        qScale.in_survey = surveyDemo

        for i in 1...5 {
            addOption(to: qScale, text: "\(i)", context: viewContext)
        }

        // SIMPAN
        do {
            try viewContext.save()
            print("✅ Seeding Berhasil Disimpan dengan Data Baru!")
        } catch {
            print("❌ Gagal menyimpan seeder: \(error.localizedDescription)")
        }
    }

    @discardableResult
    private static func addOption(
        to question: Question,
        text: String,
        context: NSManagedObjectContext
    ) -> Option {
        let opt = Option(context: context)
        opt.option_id = UUID()
        opt.option_text = text
        question.addToHas_option(opt)
        return opt
    }
}
