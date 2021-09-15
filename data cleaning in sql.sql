Select *
from nashvillehousing

-- standardize the date format

select saledateconverted, convert(date,saledate) 
from NashvilleHousing

update NashvilleHousing
set saledate= convert(date,saledate)

alter table nashvillehousing
add saledateconverted date;

update NashvilleHousing
set saledateconverted= convert(date,saledate)

-- populate property address

select *
from nashvillehousing
--where propertyaddress is null
order by parcelid

select a.parcelId, a.PropertyAddress, 
b.parcelId, b.PropertyAddress, 
isnull(a.PropertyAddress, b.PropertyAddress)
from nashvillehousing a
join nashvillehousing b
	on a.ParcelID=b.parcelId
	and a.[uniqueId]<>b.[uniqueId]
--where a.propertyaddress is null

update a
set propertyaddress = isnull(a.PropertyAddress, b.PropertyAddress)
from nashvillehousing a
join nashvillehousing b
	on a.ParcelID=b.parcelId
	and a.[uniqueId]<>b.[uniqueId]
where a.propertyaddress is null

-- breaking out address into individual columns

select propertyaddress
from nashvillehousing

select 
substring(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)
as address,
substring(propertyaddress, CHARINDEX(',',propertyaddress)+1, len(propertyaddress))
as city
from nashvillehousing

alter table nashvillehousing
add PropertySplitAddress varchar(100);

update NashvilleHousing
set PropertySplitAddress = 
substring(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)

alter table nashvillehousing
add PropertySplitCity varchar(50);

update NashvilleHousing
set PropertySplitCity = 
substring(propertyaddress, CHARINDEX(',',propertyaddress)+1, len(propertyaddress))

select *
from nashvillehousing


select owneraddress
from nashvillehousing

select
parsename(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2), 
parsename(replace(owneraddress,',','.'),1) 
from nashvillehousing

alter table nashvillehousing
add OwnerSplitAddress varchar(100);

update NashvilleHousing
set OwnerSplitAddress = 
parsename(replace(owneraddress,',','.'),3)

alter table nashvillehousing
add OwnerSplitCity varchar(50);

update NashvilleHousing
set OwnerSplitCity = 
parsename(replace(owneraddress,',','.'),2)

alter table nashvillehousing
add OwnerSplitState varchar(50);

update NashvilleHousing
set OwnerSplitState = 
parsename(replace(owneraddress,',','.'),1)

select *
from nashvillehousing

-- change Y and N to Yes and No in "Sold as vacant" field

select distinct(soldasvacant), count(soldasvacant)
from nashvillehousing
group by soldasvacant
order by 2


select soldasvacant,
case 
when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end
from nashvillehousing

update NashvilleHousing
set SoldAsVacant = case 
when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end

-- remove duplicates

with RowNumCTE as
(
select *,
	row_number() over (
	partition by parcelId, propertyaddress,
		saleprice, saledate, legalreference
 order by uniqueId) as row_num

 from nashvillehousing
 )
 
 --delete
 select *
 from RowNumCTE
 where row_num > 1

 -- delete Not used columns 

select *
from nashvillehousing

alter table nashvillehousing
drop column owneraddress, taxdistrict,propertyaddress

alter table nashvillehousing
drop column saledate

