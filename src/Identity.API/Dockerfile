FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy central package versions
COPY Directory.Packages.props ./

# Copy Identity.API project
COPY src/Identity.API/Identity.API.csproj ./src/Identity.API/

# Restore dependencies
RUN dotnet restore ./src/Identity.API/Identity.API.csproj

# Copy everything
COPY . .

# Publish Identity.API
RUN dotnet publish ./src/Identity.API/Identity.API.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

COPY --from=build /app/publish .

EXPOSE 80
ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "Identity.API.dll"]
