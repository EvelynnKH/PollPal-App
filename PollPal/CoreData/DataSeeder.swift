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

    private static func isDatabaseEmpty(viewContext: NSManagedObjectContext)
        -> Bool
    {
        let fetchRequest: NSFetchRequest<Survey> = Survey.fetchRequest()
        do {
            let count = try viewContext.count(for: fetchRequest)
            return count == 0
        } catch {
            return true  // Jika error, anggap kosong biar aman
        }
    }

    private static func createData(viewContext: NSManagedObjectContext) {

        //Category
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

        //user
        let felicia = User(context: viewContext)
        felicia.user_id = UUID()
        felicia.user_name = "Felicia Kathrin"
        felicia.user_email = "feli@gmail.com"
        felicia.user_pwd = "feli123"
        felicia.user_point = 100
        felicia.user_header_img = "mountain"
        felicia.user_profile_img = "cat"
        felicia.user_created_at = Date()
        felicia.user_status_del = false

        felicia.addToLike_category(catTech)
        felicia.addToLike_category(catDaily)

        let userCreator = User(context: viewContext)
        userCreator.user_id = UUID()
        userCreator.user_name = "Evelin"  // Nama Owner
        userCreator.user_email = "evelin@pollpal.com"
        userCreator.user_pwd = "evelin123"
        userCreator.user_header_img = "mountain"
        userCreator.user_profile_img = "cat"
        userCreator.user_point = 500
        userCreator.user_created_at = Date()
        userCreator.user_status_del = false

        //Survey
        // 1. Survey Tech
        let survey1 = Survey(context: viewContext)
        survey1.survey_id = UUID()
        survey1.survey_title = "Penggunaan AI Mahasiswa"
        survey1.survey_description =
            "Seberapa sering mahasiswa menggunakan ChatGPT untuk tugas?"
        survey1.survey_points = 50
        survey1.survey_rewards_points = 250
        survey1.survey_created_at = Date()
        survey1.is_public = true
        survey1.survey_updated_at = Date()
        survey1.survey_status_del = false
        survey1.owned_by_user = userCreator

        // Relasi Category (Many-to-Many)
        survey1.addToHas_category(catTech)

        // Tambah Dummy Question (Biar estimasi waktu muncul)
        let q1 = Question(context: viewContext)
        q1.question_id = UUID()
        q1.question_text = "Apakah kamu pakai ChatGPT?"
        q1.question_type = "Multiple Choice"
        q1.question_price = 10
        q1.question_status_del = false
        q1.in_survey = survey1

        //option
        let opt1_yes = addOption(
            to: q1,
            text: "Ya, Sering",
            context: viewContext
        )
        let opt1_no = addOption(
            to: q1,
            text: "Tidak Pernah",
            context: viewContext
        )

        let q2 = Question(context: viewContext)
        q2.question_id = UUID()
        q2.question_text = "Ceritakan pengalamanmu!"
        q2.question_type = "Long Answer"
        q2.question_price = 10
        q2.question_status_del = false
        q2.in_survey = survey1
        // 2. Survey Health (Campuran Kategori)
        let survey2 = Survey(context: viewContext)
        survey2.survey_id = UUID()
        survey2.survey_title = "Pola Tidur & Gadget"
        survey2.survey_description =
            "Hubungan main HP sebelum tidur dengan kualitas tidur."
        survey2.survey_points = 50
        survey2.survey_rewards_points = 250
        survey2.survey_created_at = Date()
        survey2.is_public = true
        survey2.survey_updated_at = Date()
        survey2.survey_status_del = false
        survey2.owned_by_user = felicia

        survey2.addToHas_category(catHealth)
        survey2.addToHas_category(catTech)  // Multi kategori

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

        // survey 3
        let survey3 = Survey(context: viewContext)
        survey3.survey_id = UUID()
        survey3.survey_title = "Evaluasi Kantin UC"
        survey3.survey_description = "Survey kepuasan pelanggan kantin lantai 1"
        survey3.survey_points = 50
        survey3.survey_rewards_points = 20
        survey3.is_public = true
        survey3.survey_created_at = Date()
        survey3.survey_updated_at = Date()
        survey3.survey_status_del = false
        survey3.owned_by_user = felicia  // Relasi: Milik Felicia

        survey3.addToHas_category(catDaily)

        // Question
        let q6 = Question(context: viewContext)
        q6.question_id = UUID()
        q6.question_text = "Apakah kamu setuju makanannya enak?"
        q6.question_type = "Short Answer"
        q6.question_price = 1
        q6.question_status_del = false
        q6.in_survey = survey1

        //hresponse, dresponse
        let hRes = HResponse(context: viewContext)
        hRes.hresponse_id = UUID()
        hRes.submitted_at = Date()
        hRes.in_survey = survey1
        hRes.is_filled_by_user = felicia

        let dRes1 = DResponse(context: viewContext)
        dRes1.dresponse_id = UUID()
        dRes1.in_hresponse = hRes  // Link ke Header
        dRes1.in_question = q1  // Link ke Pertanyaan
        dRes1.has_option = NSSet(array: [opt1_yes])   // Link ke Opsi yang dipilih
        dRes1.dresponse_answer_text = opt1_yes.option_text  // Simpan text juga

        let dRes2 = DResponse(context: viewContext)
        dRes2.dresponse_id = UUID()
        dRes2.in_hresponse = hRes
        dRes2.in_question = q2
        dRes2.dresponse_answer_text = "Sangat membantu tugas coding saya."  // Isi manual essay

        //transaction
        //transaction TYPE hanya 4 macam : TOPUP, REWARDSURVEY, COST SURVEY , WITHDRAW
        let trans = Transaction(context: viewContext)
        trans.transaction_id = UUID()
        trans.transaction_point_change = 1000
        trans.transaction_description = "Top Up Berhasil"
        trans.transaction_status_del = false
        trans.owned_by_user = felicia
        trans.transaction_created_at = Date() - 86400  // 1 day ago
        trans.transaction_type = "TOP UP"

        let trans2 = Transaction(context: viewContext)
        trans2.transaction_id = UUID()
        trans2.transaction_point_change = 50
        trans2.transaction_description =
            "Reward for filling in Survey: Kepuasan Customer"
        trans2.transaction_status_del = false
        trans2.owned_by_user = felicia
        trans2.in_survey = survey1
        trans2.transaction_created_at = Date() - 3600 * 5  // 5 hours ago
        trans2.transaction_type = "REWARD SURVEY"

        let trans3 = Transaction(context: viewContext)
        trans3.transaction_id = UUID()
        trans3.transaction_point_change = -1000
        trans3.transaction_description =
            "Survey Cost: Riset Pasar Produk Baru"
        trans3.transaction_status_del = false
        trans3.owned_by_user = felicia
        trans3.in_survey = survey2
        trans3.transaction_created_at = Date() - 3600 * 24 * 3  // 3 days ago
        trans3.transaction_type = "COST SURVEY"

        let trans4 = Transaction(context: viewContext)
        trans4.transaction_id = UUID()
        trans4.transaction_point_change = -500
        trans4.transaction_description = "Withdraw Points"
        trans4.transaction_status_del = false
        trans4.owned_by_user = felicia
        trans4.transaction_created_at = Date() - 3600 * 2  // 2 hours ago
        trans4.transaction_type = "WITHDRAW"

        //survey baru
        let surveyDemo = Survey(context: viewContext)
        surveyDemo.survey_id = UUID()
        surveyDemo.survey_title = "Survey Kepuasan Karyawan"
        surveyDemo.survey_description =
            "Demo semua tipe soal: Pilihan Ganda, Isian, Kotak Centang, dll."
        surveyDemo.survey_points = 100
        surveyDemo.survey_rewards_points = 500
        surveyDemo.survey_created_at = Date()
        surveyDemo.is_public = true
        surveyDemo.survey_status_del = false
        surveyDemo.owned_by_user = userCreator

        surveyDemo.addToHas_category(catDaily)  // Masuk kategori Daily

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
        qPara.question_text =
            "Jelaskan kendala terbesar anda saat bekerja di kantor ini?"
        qPara.question_type = "Paragraph"
        qPara.question_price = 15
        qPara.question_status_del = false
        qPara.in_survey = surveyDemo

        // Q4: Check Box (Bisa pilih lebih dari satu)
        let qCheck = Question(context: viewContext)
        qCheck.question_id = UUID()
        qCheck.question_text =
            "Fasilitas apa yang sering anda gunakan? (Pilih semua yang sesuai)"
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

        // Q6: Linear Scale (1-5)
        // Kita gunakan Option sebagai angka skalanya
        let qScale = Question(context: viewContext)
        qScale.question_id = UUID()
        qScale.question_text =
            "Seberapa puas anda dengan gaji saat ini? (1 = Kecewa, 5 = Sangat Puas)"
        qScale.question_type = "Linear Scale"
        qScale.question_price = 10
        qScale.question_status_del = false
        qScale.in_survey = surveyDemo

        // Seed angka 1 sampai 5 sebagai opsi
        for i in 1...5 {
            addOption(to: qScale, text: "\(i)", context: viewContext)
        }

        //simpan
        do {
            try viewContext.save()
            print("✅ Seeding Berhasil Disimpan!")
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
        // Relasi ke Question (Pastikan relationship 'has_option' di core data tipe To Many)
        question.addToHas_option(opt)
        return opt
    }
}
