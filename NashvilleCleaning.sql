--Data Cleaning
-- Link to the data set used : https://github.com/StefanConradie/PortfolioFiles/blob/57f57e3a1686079ddece51a03993ffa02e0ea5c1/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx


Use PortfolioProject

--Change Sale date

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.Nashville;


Update PortfolioProject..Nashville
SET SaleDate = CONVERT(Date,SaleDate);


Alter table PortfolioProject..Nashville
Add SaleDateConverted Date;

Update PortfolioProject..Nashville
SET SaleDateConverted = CONVERT(Date,SaleDate);


--Populate NULL Property adresses

Select *
From PortfolioProject..Nashville
--where PropertyAddress is null
Order by ParcelID;


Select nr1.ParcelID, nr1.PropertyAddress, nr2.ParcelID, nr2.PropertyAddress, ISNULL(nr1.PropertyAddress, nr2.PropertyAddress)
From PortfolioProject..Nashville nr1
Join PortfolioProject..Nashville nr2
	on nr1.ParcelID = nr2.ParcelID
	And nr1.[UniqueID ]<>nr2.[UniqueID ]
Where nr1.PropertyAddress is NULL;


Update nr1
SET PropertyAddress = ISNULL(nr1.PropertyAddress,nr2.PropertyAddress)
From PortfolioProject..Nashville nr1
Join PortfolioProject..Nashville nr2
	on nr1.ParcelID = nr2.ParcelID
	And nr1.[UniqueID ]<>nr2.[UniqueID ]
Where nr1.PropertyAddress is NULL;


--Break Address into different Columns

Select PropertyAddress
From PortfolioProject..Nashville


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address
From PortfolioProject..Nashville;


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) As City
From PortfolioProject..Nashville;


Alter table Nashville
Add PropertyAdressSplit NVarchar(255);

Update Nashville
SET PropertyAdressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

Alter table Nashville
Add PropertyCitySplit NVarchar(255);

Update Nashville
SET PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));



--Break up Owner Address


Select 
PARSENAME(Replace(OwnerAddress,',','.'),3)
, PARSENAME(Replace(OwnerAddress,',','.'),2)
, PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProject..Nashville;



Alter table Nashville
Add OwnerAdressSplit NVarchar(255);

Update Nashville
SET OwnerAdressSplit = PARSENAME(Replace(OwnerAddress,',','.'),3);

Alter table Nashville
Add OwnerCitySplit NVarchar(255);

Update Nashville
SET OwnerCitySplit = PARSENAME(Replace(OwnerAddress,',','.'),2);

Alter table Nashville
Add OwnerStateSplit NVarchar(255);

Update Nashville
SET OwnerStateSplit = PARSENAME(Replace(OwnerAddress,',','.'),1);


--Change Values in 'Sold in Vacant' from Y to Yes and N to No

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..Nashville
Group by SoldAsVacant
Order by 2;


Select SoldAsVacant
, Case when SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject..Nashville;


Update Nashville
Set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject..Nashville;



--Removing Duplicates

--Using CTE

With RowNumCTE As (
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
From PortfolioProject..Nashville
--order by ParcelID
)
Select * 
From RowNumCTE
where row_num > 1
Order by PropertyAddress;


--Delete them

With RowNumCTE As (
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
From PortfolioProject..Nashville
--order by ParcelID
)
Delete 
From RowNumCTE
where row_num > 1;




--Delete Unused Columns

Select * 
From PortfolioProject..Nashville


Alter table PortfolioProject..Nashville
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;


