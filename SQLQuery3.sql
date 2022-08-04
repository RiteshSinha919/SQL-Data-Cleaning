select * from portfolio..housing
select count(*) from portfolio..housing



-- date format
select SaleDate from portfolio..housing
-- update portfolio..housing set SaleDate = CONVERT(date,SaleDate);
alter table portfolio..housing add saledateconverted date;
update portfolio..housing set saledateconverted = convert(date,saledate)
select saledateconverted from portfolio..housing



--cleaning property address
select propertyaddress from portfolio..housing 
select parcelid,propertyaddress from portfolio..housing where propertyaddress is null
select * from portfolio..housing order by parcelid

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio..housing a
JOIN portfolio..housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio..housing a
JOIN portfolio..housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

select count(propertyaddress) from portfolio..housing where propertyaddress is null



-- breaking property address
select propertyaddress from portfolio..housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
From Portfolio..Housing

ALTER TABLE portfolio..housing
Add PropertySplitAddress Nvarchar(255);

Update portfolio..housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE portfolio..housing
Add PropertySplitCity Nvarchar(255);

Update portfolio..housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select * from portfolio..housing



-- breaking owner address
select owneraddress from portfolio..housing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as Address
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as City
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as State
From Portfolio..Housing

ALTER TABLE Portfolio..Housing
Add OwnerSplitAddress Nvarchar(255);

Update Portfolio..Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Portfolio..Housing
Add OwnerSplitCity Nvarchar(255);

Update Portfolio..Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Portfolio..Housing
Add OwnerSplitState Nvarchar(255);

Update Portfolio..Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select * from portfolio..housing


-- Cleaning Soldasvacant
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio..Housing
Group by SoldAsVacant
order by 2

Select SoldAsVacant, 
	   CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Portfolio..Housing


Update Portfolio..Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

select Distinct(SoldAsVacant) from portfolio..housing



--Removing Duplicates (Not a best practice)
WITH ranking AS(Select *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID row_num)
	From Portfolio..Housing)

Select * From ranking Where row_num > 1 Order by PropertyAddress

delete from ranking Where row_num > 1



--Remove Unused columns
Select * From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate