//
//  SettingsView.swift
//  TubeShield
//

import SwiftUI
import WebKit

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    @State private var showClearAlert = false
    @State private var clearedMessage = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("TÍNH NĂNG CHẶN QUẢNG CÁO")) {
                    Toggle(isOn: $settings.isAdBlockEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Chặn quảng cáo (AdBlock)")
                                    .font(.body)
                                Text("Chặn video ad pre-roll, mid-roll và banner")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "shield.checkered")
                                .foregroundColor(.red)
                        }
                    }
                    
                    Toggle(isOn: $settings.isSponsorBlockEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Tự động bỏ qua tài trợ (SponsorBlock)")
                                    .font(.body)
                                Text("Bỏ qua các đoạn quảng cáo lồng ghép trong video")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "bolt.badge.clock.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                Section(header: Text("ÂM THANH & HÌNH ẢNH")) {
                    Toggle(isOn: $settings.isBackgroundPlayEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Phát trong nền (Background Audio)")
                                    .font(.body)
                                Text("Nghe nhạc khi khoá màn hình hoặc chuyển app")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(.cyan)
                        }
                    }
                    
                    Toggle(isOn: $settings.isAutoPiPEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Tự động mở Picture-in-Picture")
                                    .font(.body)
                                Text("Thu nhỏ video thành cửa sổ nổi khi thoát màn hình")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "pip.enter")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Toggle(isOn: $settings.desktopMode) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Giao diện máy tính (Desktop)")
                                    .font(.body)
                                Text("Tải giao diện YouTube chuẩn cho màn hình lớn")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "display")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("CHẾ ĐỘ YOUTUBE MUSIC & AUDIO ONLY")) {
                    Toggle(isOn: $settings.isAudioOnlyMode) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Chỉ nghe âm thanh (Audio-Only)")
                                    .font(.body)
                                Text("Tắt video, hạ chất lượng xuống 144p để tiết kiệm 90% pin & 4G")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "headphones")
                                .foregroundColor(.cyan)
                        }
                    }
                    
                    Toggle(isOn: $settings.isMusicMode) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Chế độ YouTube Music")
                                    .font(.body)
                                Text("Sử dụng giao diện music.youtube.com")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "music.note.list")
                                .foregroundColor(.pink)
                        }
                    }
                }
                
                Section(header: Text("DỮ LIỆU & BỘ NHỚ")) {
                    Button(role: .destructive) {
                        showClearAlert = true
                    } label: {
                        Label("Xoá bộ nhớ đệm & Cookies", systemImage: "trash")
                    }
                    .alert("Xác nhận xoá", isPresented: $showClearAlert) {
                        Button("Xoá tất cả", role: .destructive) {
                            clearWebsiteData()
                        }
                        Button("Huỷ", role: .cancel) {}
                    } message: {
                        Text("Thao tác này sẽ đăng xuất tài khoản YouTube và xoá cache webview.")
                    }
                    
                    if clearedMessage {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Đã dọn dẹp bộ nhớ đệm thành công!")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Section(header: Text("THÔNG TIN")) {
                    HStack {
                        Text("Phiên bản")
                        Spacer()
                        Text("1.0.0 (iOS 18)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Phát triển bởi")
                        Spacer()
                        Text("TubeShield Studio")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Cài đặt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Xong") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func clearWebsiteData() {
        let dataStore = WKWebsiteDataStore.default()
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        dataStore.fetchDataRecords(ofTypes: types) { records in
            dataStore.removeData(ofTypes: types, for: records) {
                DispatchQueue.main.async {
                    self.clearedMessage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.clearedMessage = false
                    }
                }
            }
        }
    }
}
