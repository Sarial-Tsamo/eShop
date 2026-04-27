FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy central package versions
COPY Directory.Packages.props ./

# Copy Identity.API project
COPY src/Ordering.API/Ordering.API.csproj ./src/Ordering.API/

# Restore dependencies
RUN dotnet restore ./src/Ordering.API/Ordering.API.csproj

# Copy everything
COPY . .

# Publish Ordering.API
RUN dotnet publish ./src/Ordering.API/Ordering.API.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

COPY --from=build /app/publish .

EXPOSE 80
ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "Ordering.API.dll"]

