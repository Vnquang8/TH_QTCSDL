USE QuanLyLuong
GO
--BAI 1A
CREATE FUNCTION TONG2SONGUYEN (@A INT,@B INT)
RETURNS INT
AS
BEGIN
	RETURN @A + @B
END
GO
SELECT DBO.TONG2SONGUYEN(1,2)
--BAI 1B
ALTER FUNCTION PTB1 (@A FLOAT,@B FLOAT)
RETURNS NVARCHAR(50)
AS
BEGIN
	IF @A = 0
	BEGIN
		IF @B = 0
		RETURN 'PHUONG TRINH VO SO NGHIEM'
		ELSE
		RETURN 'PHUONG TRINH VO NGHIEM'
	END
		RETURN 'PHUONG TRINH CO NGHIEM LA' + CONVERT(NVARCHAR(50),-@B/@A)
END
GO
SELECT DBO.PTB1(0,1)
--BAI 1C
create function tinhTuoi(@ngaysinh date)
returns int
as
begin
	return datediff(YY,@ngaysinh,getdate())
end
go
SELECT DBO.tinhTuoi ('2002/07/16')

--BAI 2A
CREATE FUNCTION CAU3A()
RETURNS TABLE
AS
	RETURN (SELECT TenNhanVien, DBO.tinhTuoi(NgaySinh)AS TUOI FROM NhanVien)
GO
SELECT*FROM CAU3A()
--BAI 2B
CREATE FUNCTION CAU3B()
RETURNS TABLE
AS
	RETURN (SELECT NhanVien.MaNhanVien,NhanVien.TenNhanVien,
	(LuongCoBan/24*SoNgayCong-TienTamUng+TienHoanTra)AS LUONGTHUCLANH
	
	FROM NhanVien JOIN BangLuong ON NhanVien.MaNhanVien = BangLuong.MaNhanVien )
GO
SELECT * FROM CAU3B()
--BAI 2C
CREATE FUNCTION CAU3C (@THANG INT)
RETURNS TABLE
AS
	RETURN (SELECT NhanVien.MaNhanVien,NhanVien.TenNhanVien,
	(LuongCoBan/24*SoNgayCong-TienTamUng+TienHoanTra)AS LUONGTHUCLANH
	
	FROM NhanVien JOIN BangLuong ON NhanVien.MaNhanVien = BangLuong.MaNhanVien 
	WHERE MONTH(NgayTinhLuong) = @THANG)
GO
SELECT * FROM CAU3C(5)
--BAI 4A
CREATE FUNCTION CAU4A()
RETURNS @DS TABLE(MANV NVARCHAR(50), TENNV NVARCHAR(50), LUONGTL FLOAT)
AS
BEGIN
	insert into @ds
	select NhanVien.MaNhanVien, NhanVien.TenNhanVien,
	NhanVien.LuongCoBan/24*BangLuong.SoNgayCong - BangLuong.TienTamUng + BangLuong.TienHoanTra as LuongThucLanh
	from NhanVien inner join BangLuong on NhanVien.MaNhanVien = BangLuong.MaNhanVien
	where MONTH(NgayTinhLuong) = MONTH(getdate())
	return
END
GO
SELECT * FROM CAU4A()

--BAI 4B
CREATE FUNCTION CAU4B()
RETURNS @DS TABLE(MANV NVARCHAR(50),NGAYCONG INT)
AS
BEGIN
	INSERT INTO @DS
	SELECT MaNhanVien,SUM(SoNgayCong) FROM BangLuong
	GROUP BY MaNhanVien
	RETURN
END
GO
SELECT * FROM CAU4B()

--BAI 5A
CREATE FUNCTION BAI5(@MNV NVARCHAR(50),@THANG INT,@NAM INT)
RETURNS FLOAT
AS
BEGIN
	DECLARE @LG FLOAT
	SELECT @LG = NhanVien.LuongCoBan/24*BangLuong.SoNgayCong - BangLuong.TienTamUng + BangLuong.TienHoanTra 
	from NhanVien inner join BangLuong on NhanVien.MaNhanVien = BangLuong.MaNhanVien
	WHERE MONTH(NgayTinhLuong)=@THANG AND YEAR(NgayTinhLuong)=@NAM AND NHANVIEN.MaNhanVien = @MNV
	RETURN @LG
END
GO
select dbo.BAI5('NV01',4,2023)
--BAI 6
CREATE FUNCTION BAI6(@TIME DATE)
RETURNS @DS TABLE (MANV NVARCHAR(50),TENNV NVARCHAR(50),NGAYSINH DATE,LUONGTL FLOAT)
AS
BEGIN
	INSERT INTO @DS
	SELECT NhanVien.MaNhanVien, NhanVien.TenNhanVien, NhanVien.NgaySinh, 
	DBO.BAI5(NhanVien.MaNhanVien,MONTH(@TIME),YEAR(@TIME))
	FROM NhanVien JOIN BangLuong ON NhanVien.MaNhanVien = BangLuong.MaNhanVien
	RETURN
END
GO
SELECT * FROM BAI6(GETDATE())
--BAI 7
CREATE FUNCTION BAI7(@MDA NVARCHAR(50))
RETURNS INT
AS
BEGIN
	DECLARE @SUM INT
	SELECT @SUM = SUM(LuongCoBan)FROM NhanVien
	WHERE NhanVien.MaNhanVien IN (SELECT ThamGia.MaNhanVien FROM ThamGia WHERE ThamGia.MaDeAn = @MDA)
	RETURN @SUM
END
GO
SELECT  dbo.BAI7('DA02')

--BAI 9 
SELECT * FROM ThamGia
CREATE FUNCTION BAI9(@MNV NVARCHAR(50))
RETURNS INT
AS
BEGIN
	DECLARE @SUM INT
	SELECT @SUM = SUM(ThoiGian) FROM ThamGia
	WHERE ThamGia.MaNhanVien = @MNV
	RETURN @SUM
END
SELECT DBO.BAI9 ('NV01')

--BAI 10
CREATE FUNCTION BAI10()
RETURNS @DS TABLE(MNV NVARCHAR(50),TENNV NVARCHAR(50),TENPB NVARCHAR(50),TONGTIME INT)
AS
BEGIN
	INSERT INTO @DS
    SELECT NV.MaNhanVien, NV.TenNhanVien, PB.TenPhongBan,dbo.BAI9(TG.MaNhanVien)
    FROM NhanVien NV
    JOIN PhongBan PB ON NV.MaPhongBan = PB.MaPhongBan
    JOIN ThamGia TG ON NV.MaNhanVien = TG.MaNhanVien
	RETURN
END
GO
SELECT * FROM BAI10()

