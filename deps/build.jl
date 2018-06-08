using Base.Filesystem
using BinDeps: unpack_cmd, download_cmd


const meshcat_sha = "18028760b377c178bc77ee61cf4b9de8d176d3c5"
const meshcat_url = "https://github.com/rdeits/meshcat/archive/$meshcat_sha.zip"

const assets_dir = normpath(joinpath(@__DIR__, "..", "assets"))
const meshcat_dir = joinpath(assets_dir, "meshcat")
const stamp_file = joinpath(assets_dir, "meshcat.stamp")

function update_meshcat()
    if !isdir(assets_dir)
        mkpath(assets_dir)
    end

    if isdir(joinpath(meshcat_dir, ".git"))
        info("Meshcat assets in $meshcat_dir have been cloned with git, so they will not be automatically downloaded. To force a re-download, delete or rename the directory $meshcat_dir")
        return
    end
    if isfile(stamp_file)
        stamped_sha = strip(open(readstring, stamp_file))
        if stamped_sha == meshcat_sha 
            return
        else
            info("Updating meshcat assets in $meshcat_dir from SHA $stamped_sha to $meshcat_sha")
        end
    end

    if isdir(meshcat_dir)
        rm(meshcat_dir; recursive=true)
    end

    mktempdir() do download_dir
        download_path = joinpath(download_dir, "meshcat.zip")
        run(DownloadHelpers.download_cmd(meshcat_url, download_path))
        run(DownloadHelpers.unpack_cmd(download_path, download_dir, ".zip", nothing))
        mv(joinpath(download_dir, "meshcat-$meshcat_sha"), meshcat_dir; remove_destination=true)
    end
    open(stamp_file, "w") do file
        print(file, meshcat_sha)
    end
end

update_meshcat()
